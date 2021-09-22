# Creating the Lab VM

1. On the Azure Powershell, run:
    ```bash
    ./quickstart/scripts/labvm/Deploy-LabVM.ps1
    ```

    - Use the following value for the the `sourceSas` parameter: `https://stlabvm.blob.core.windows.net/vhd/labvm-001.vhd?sp=r&st=2021-09-21T19:04:44Z&se=2021-09-25T03:04:44Z&spr=https&sv=2020-08-04&sr=b&sig=qJATNoRXYE34IBybuAMTaMzWyPTr8mZSp3EiYFoRnLk%3D`

2. After the VM is created, assign a new password to the user `labuser`.
    
    ![Reset VM password](./images/vm-lab-reset-password.png)

3. Connect to the VM using a RDP client:

    ![RDP Access to the Lab VM](./images/vm-lab-rdp-connection.png)

