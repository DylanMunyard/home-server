# Load Balancer

After deploying go to :8080 and create username and password.

Create new file munyard.dev.conf from Manage Configs > conf.d -> Create File
- Paste in [munyard.dev.conf](munyard.dev.conf)	
	
## Origin Server SSL 
1. In CloudFlare set encryption mode to 'Full (Strict)' under the domain's SSL/TLS settings.
2. Generate an Origin Certificate in CloudFlare https://developers.cloudflare.com/ssl/origin-configuration/origin-ca/
3. Create munyard.dev.pem and munyard.dev.key under Manage Configs > conf.d > Create File and paste in the keys