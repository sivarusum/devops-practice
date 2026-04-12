#!/bin/bash

export PATH=/usr/local/bin:/usr/bin:/bin

REPORT_FILE="/home/ubuntu/scripts/report.txt"

# Clear old report
> $REPORT_FILE

echo "===== AWS Usage Report =====" >> $REPORT_FILE
echo "Generated on: $(date)" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# -----------------------------
# EC2 Instances
# -----------------------------
echo "=== EC2 Instances ===" >> $REPORT_FILE
aws ec2 describe-instances \
  --query 'Reservations[].Instances[].InstanceId' \
  --output text >> $REPORT_FILE
echo "" >> $REPORT_FILE

# -----------------------------
# S3 Buckets and Size
# -----------------------------
echo "=== S3 Buckets ===" >> $REPORT_FILE
for bucket in $(aws s3 ls | awk '{print $3}'); do
    size=$(aws s3 ls s3://$bucket --recursive --human-readable --summarize | grep "Total Size" | awk '{print $3,$4}')
    echo "$bucket --> $size" >> $REPORT_FILE
done
echo "" >> $REPORT_FILE

# -----------------------------
# IAM Users
# -----------------------------
echo "=== IAM Users ===" >> $REPORT_FILE
aws iam list-users --query 'Users[].UserName' --output text >> $REPORT_FILE
echo "" >> $REPORT_FILE

# -----------------------------
# Lambda Functions
# -----------------------------
echo "=== Lambda Functions ===" >> $REPORT_FILE
aws lambda list-functions --query 'Functions[].FunctionName' --output text >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "===== End of Report =====" >> $REPORT_FILE

# 📧 Send Email
mail -s "AWS Usage Report" sivarusum76@gmail.com < $REPORT_FILE

