# Cowrie Honeypot Deployment on AWS

## Overview
This project demonstrates the deployment of a Cowrie honeypot on Amazon Web Services (AWS) with automated monitoring, email alerts, and log storage capabilities.

## Features
- 🛡️ **Cowrie SSH Honeypot** - Simulates vulnerable SSH services
- 📧 **Email Alerts** - Real-time notifications of login attempts
- 🌍 **Geolocation Tracking** - Identifies attacker locations
- ☁️ **AWS S3 Integration** - Automated log storage
- 📊 **Monitoring Dashboard** - Track attack patterns

## Architecture
```
Internet → EC2 Instance (Cowrie) → Email Alerts + S3 Storage
```

## Prerequisites
- AWS Account with EC2 and S3 access
- Basic knowledge of Linux command line
- Email account for alerts (Gmail recommended)

## Quick Start

### 1. AWS Setup
```bash
# Create EC2 instance with Ubuntu AMI
# Configure security groups (allow SSH on port 2222)
# Create IAM role with S3 access
```

### 2. Install Dependencies
```bash
sudo apt update
sudo apt install -y git python3 python3-pip python3-venv build-essential libssl-dev
```

### 3. Deploy Cowrie
```bash
git clone https://github.com/cowrie/cowrie.git
cd cowrie
python3 -m venv cowrie-env
source cowrie-env/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

### 4. Configure Monitoring
```bash
# Copy the monitoring script
cp scripts/cowrie_email_alerts.sh ~/cowrie/
chmod +x ~/cowrie/cowrie_email_alerts.sh

# Configure email settings (see docs for details)
```

### 5. Start the Honeypot
```bash
cd ~/cowrie
bin/cowrie start
./cowrie_email_alerts.sh
```

## Configuration

### Email Alerts Setup
1. Install msmtp: `sudo apt install msmtp`
2. Configure `~/.msmtprc` with your email settings
3. Set proper permissions: `chmod 600 ~/.msmtprc`

### S3 Bucket Configuration
1. Create S3 bucket in AWS console
2. Attach IAM role to EC2 instance
3. Update bucket name in monitoring script

## Testing
Test the honeypot by connecting via SSH:
```bash
ssh -p 2222 root@<your-ec2-public-ip>
```

## Monitoring Script Features
- **Real-time log monitoring** using `tail -f`
- **Geolocation lookup** via ip-api.com
- **Email notifications** for login attempts
- **Command logging** and execution tracking
- **Automated S3 uploads** for data persistence

## Sample Output
The system captures:
- Username and password attempts
- Attacker IP addresses and geolocation
- Commands executed during sessions
- Session duration and patterns

## Security Considerations
- ⚠️ **Isolation**: Deploy in isolated network environment
- 🔒 **Access Control**: Restrict management access
- 📝 **Logging**: Ensure comprehensive log retention
- 🚨 **Monitoring**: Set up alerts for unusual activity

## Troubleshooting

### Common Issues
1. **Port 2222 blocked**: Check security group settings
2. **Email not sending**: Verify msmtp configuration
3. **S3 upload fails**: Check IAM role permissions
4. **Cowrie won't start**: Check Python virtual environment

### Logs Location
- Cowrie logs: `~/cowrie/var/log/cowrie/cowrie.log`
- System logs: `/var/log/syslog`
- Email logs: Check msmtp configuration


## Author
**Aquil Ilyas**
- Email: aquil.ilyas@gmail.com
- Project: Honeypot Deployment on AWS
