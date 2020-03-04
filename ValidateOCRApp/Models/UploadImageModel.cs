using System;
namespace ValidateOCRApp.Models
{
    public class UploadImageModel
    {

        public bool IsApproved { get; set; }
        public byte[] BlobContents { get; set; }
        public string ImageName { get; set; }

    }
}
