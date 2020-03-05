using System;
using System.IO;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using Microsoft.WindowsAzure.Storage.Queue;
using Newtonsoft.Json;
using ValidateOCRApp.Models;

namespace ValidateOCRApp
{
    public static class ValidateOCRApp
    {

        private static CloudBlockBlob GetBlobReference(string containerNameString,
                                                       string imageNameString)
        {

            
            CloudStorageAccount cloudStorageAccount = null;
            var connectionString = Environment.GetEnvironmentVariable("AzureWebJobsStorage");
            var couldParse = CloudStorageAccount.TryParse(connectionString, out cloudStorageAccount);
            if (couldParse == false)
                return null;

            var cloudBlobClient = cloudStorageAccount.CreateCloudBlobClient();
            var blobContainerReference = cloudBlobClient.GetContainerReference(containerNameString);
            var blobReference = blobContainerReference.GetBlockBlobReference(imageNameString);
            return blobReference;

        }

        private static async Task UploadImageToBlobAsync(byte[] uploadBytesArray,
                                                         string imageNameString)
        {

            var containerNameString = Environment.GetEnvironmentVariable("APPROVED_BLOB_NAME");
            var blobReference = GetBlobReference(containerNameString, imageNameString);

            await blobReference.UploadFromByteArrayAsync(uploadBytesArray, 0,
                                                         uploadBytesArray.Length);

        }

        [FunctionName("ProcessBlobContents")]
        public static async Task ProcessBlobContents([OrchestrationTrigger]
                                                     DurableOrchestrationContext context)
        {

            var blobInfoModel = context.GetInput<BlobInfoModel>();
            var blobContents = blobInfoModel.BlobContents;

            var parsedOCRString = await context.CallActivityAsync<string>("ParseOCR",
                                                                          blobContents);

            var ocrInfoModel = JsonConvert.DeserializeObject<OCRInfoModel>(parsedOCRString);
            var approvalModel = new ApprovalModel()
            {
                InstanceId = context.InstanceId,
                Language = ocrInfoModel.Language

            };

            await context.CallActivityAsync("SendForApproval", approvalModel);

            using (var cts = new CancellationTokenSource())
            {

                var dueTime = context.CurrentUtcDateTime.AddMinutes(3);
                var timerTask = context.CreateTimer(dueTime, cts.Token);
                var approvalTask = context.WaitForExternalEvent<bool>("Approval");                
                var completedTask = await Task.WhenAny(approvalTask, timerTask);

                var isApproved = approvalTask.Result;
                var uploadImageModel = new UploadImageModel()
                {

                    IsApproved = isApproved,
                    BlobContents = blobContents,
                    ImageName = blobInfoModel.ImageName

                };

                await context.CallActivityAsync("PostApproval", uploadImageModel);                

            }
        }

        [FunctionName("PostApproval")]
        public static async Task PostApprovalAsync([ActivityTrigger]
                                                    UploadImageModel uploadImageModel,
                                                    ILogger logger)
        {

            var isApproved = uploadImageModel.IsApproved;
            logger.LogInformation($"Approved:{isApproved}");
            if (isApproved == true)            
                await UploadImageToBlobAsync(uploadImageModel.BlobContents,
                                             uploadImageModel.ImageName);           

        }

        [FunctionName("ParseOCR")]
        public static async Task<string> ParseOCRAsync([ActivityTrigger] byte[] blobContents,
                                                       ILogger logger)
        {

            var client = new HttpClient();
            var apiKeyString = Environment.GetEnvironmentVariable("OCR_API_KEY");
            client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", apiKeyString);

            var content = new ByteArrayContent(blobContents);
            content.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");
            
            var ocrResponse = await client.PostAsync(Environment.GetEnvironmentVariable("OCR_URL"),
                                                     content);
            var parsedOCR = await ocrResponse.Content.ReadAsStringAsync();
            logger.LogInformation($"OCR = {parsedOCR}");
            return parsedOCR;

        }

        [FunctionName("SendForApproval")]
        public static async Task UploadBlobAsync([ActivityTrigger] ApprovalModel approvalModel,
                                                [Queue("ocrinfoqueue")]
                                                IAsyncCollector<CloudQueueMessage>
                                                cloudQueueMessageCollector,
                                                ILogger log)
        {

            var approvalModelString = JsonConvert.SerializeObject(approvalModel);
            var cloudQueueMessage = new CloudQueueMessage(approvalModelString);
            await cloudQueueMessageCollector.AddAsync(cloudQueueMessage);
            
        }


        [FunctionName("ValidateOCRAppStart")]
        public static async Task ValidateOCRAppStart([BlobTrigger("ocrinfoblob/{name}")]
                                                        CloudBlockBlob cloudBlockBlob,
                                                        [Blob("ocrinfoblob/{name}",
                                                        FileAccess.ReadWrite)]
                                                        byte[] blobContents,
                                                        [OrchestrationClient]DurableOrchestrationClient                                                    
                                                        starter, ILogger logger)
        {

            var blobInfoModel = new BlobInfoModel()
            {

                ImageName = cloudBlockBlob.Name,
                BlobContents = blobContents

            };

            string instanceId = await starter.StartNewAsync("ProcessBlobContents", blobInfoModel);
            logger.LogInformation($"Started orchestration with ID = '{instanceId}'.");
          
        }
    }
}