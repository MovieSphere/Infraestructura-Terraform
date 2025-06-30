resource "aws_s3_bucket_notification" "frontend_2" {
  bucket = aws_s3_bucket.frontend.id

  topic {
    topic_arn = aws_sns_topic.object_created.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
    
