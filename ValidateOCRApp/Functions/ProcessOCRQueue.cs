using System;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Microsoft.WindowsAzure.Storage.Queue;
using Newtonsoft.Json;
using ValidateOCRApp.Models;

namespace ValidateOCRApp
{
    public static class ProcessOCRQueue
    {
        [FunctionName("ProcessQueue")]
        public static async Task ProcessQueueAsync([QueueTrigger("ocrinfoqueue")]
                                                   CloudQueueMessage cloudQueueMessage,                                                   
                                                   [OrchestrationClient] DurableOrchestrationClient
                                                    client, ILogger log)
        {

            var queueMessageString = cloudQueueMessage.AsString;
            log.LogDebug(queueMessageString);

            var approvalModel = JsonConvert.DeserializeObject<ApprovalModel>(queueMessageString);
            var languageString = approvalModel.Language;
            //shouldApprove
            bool shouldApprove = (string.Compare(languageString, "unk",
                                  StringComparison.CurrentCultureIgnoreCase) != 0);

            await client.RaiseEventAsync(approvalModel.InstanceId, "Approval", shouldApprove);


        }
       
    }
}
