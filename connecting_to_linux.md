# Using a shared Linux environment
To ensure a consistent experience and bypass some complexity in software installation, we have created a temporary shared Linux environment. Login/password will be communicated to participants individually.

Please note that this environment is optimized for the exercises in this particular workshop but is likely unsuitable for analyzing your
specific datasets. In particular:
• It is not sized for compute or storage intensive operations.
• It is not secured for sensitive data of any kind.
• This environment is temporary and will be removed shortly after the
conclusion of the workshop.

## Connecting to a Linux environment

The following steps verify that your account is working. To complete this check,
you will need:
- A Macintosh or Windows workstation connected to the internet.
  - Windows users should have GitBash installed. (See [Windows setup](setup_instructions.md#windows-setup) for details on installing GitBash.)
- An individual **username** and **password** supplied by the workshop hosts.
- About 5 minutes.

1. Launch your command line terminal (**GitBash** in Windows or **Terminal** in MacOS)

2. Type the following command, replacing the **YOUR_USERNAME** with the username supplied to you by the workshop hosts. Hit enter to execute the command. Note: you can copy the command below to the clipboard and then right-click in the command window to paste.

   ```ssh YOUR_USERNAME@50.17.210.255```

   The first time you run this command, you may see a prompt like the following; hit the Enter key to continue.

	```
   The authenticity of host '...' can't be established.
   ECDSA key fingerprint is SHA256:izeVPFh3fZEFP....
   Are you sure you want to continue connecting (yes/no)? yes
	```

   The command will print a warning (e.g. Warning: Permanently added ‘SERVER_ADDRESS’ (ECDSA) to the list of known hosts). This is fine.

3. When prompted,  type the password supplied by the workshop hosts. (Note this
   password is case sensitive.) If you successfully logged in, the command window should show a command prompt that looks something like this:

   ```
   Welcome to RNA-Seq Demystified
   ------------------------------
   ...
   (/rsd/conda/workshop) YOUR_USER_NAME@ip:~$
   ```

4. Cut and paste the following command and type enter/return to execute:

   ```python -c 'import this' | head -n 3 | tail -n 1```

   You should see:

   ``` Beautiful is better than ugly. ```

5. If you see the message above, your connection to the server is working. You can
   close this window (or type exit).


If you are not able to login, please see [How to get help](setup_instructions#how-to-get-help) for more assistance.
