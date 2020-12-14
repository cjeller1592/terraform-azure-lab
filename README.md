# My First Azure lab with Terraform

Creating a simple lab on Azure (one Kali box and one Ubuntu box on a network) using Terraform.

This is a simple cybersecurity lab in Azure using Terraform — a virtual network with a Kali Linux box and an Ubuntu box. It's been fun to spin the lab up and try some Kali tools on the Ubuntu box, whether that's mapping out the private network using Nmap or cracking the Ubuntu box's SSH password using Hydra. 

All you need is [Terraform](https://www.terraform.io/downloads.html), an Azure account, and the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (learn about authenticating into Azure to use Terraform [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli#logging-into-the-azure-cli))

To give it a shot, run the script — that will create the lab and automatically log you into the Kali box (you'll need to give your local password for the sudo chmod command and click "yes" for the RSA fingerprint to SSH into the Kali box)

```
./lab.sh
```
