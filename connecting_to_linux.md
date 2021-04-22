## Connecting to a Linux environment
1. Launch your command line terminal (GitBash in Windows or Terminal in MacOS)

2. Type the following command, replacing the YOUR_USERNAME and SERVER_ADDRESS with
   the username and servername supplied to you by the workshop hosts. Hit enter to execute the command. Note: you can copy the command below to the clipboard and then right-click in the command window to paste.

>      ssh YOUR_USERNAME@50.17.210.255

    The first time you run this command, you may see a prompt like the following; hit the Enter key to continue.

>       The authenticity of host '...' can't be established.
        ECDSA key fingerprint is SHA256:izeVPFh3fZEFP....
        Are you sure you want to continue connecting (yes/no)? yes

    The command will print a warning (e.g. Warning: Permanently added ‘SERVER_ADDRESS’ (ECDSA) to the list of known hosts). This is fine.


3. When prompted,  type the password supplied by the workshop hosts. (Note this
   password is case sensitive.) If you successfully logged in, the command window should show a command prompt that looks something like this:

>        ------------------------------
        Welcome to RNA-Seq Demystified
        ------------------------------
        ...
        (/rsd/conda/workshop) YOUR_USER_NAME@ip:~$

4. Cut and paste the following command and type enter/return to execute:

>        python -c 'import this' | head -n 3 | tail -n 1

   You should see:

>        Beautiful is better than ugly.

5. If you see the message above, your connection to the server is working. You can
   close this window (or type exit).


If you are not able to login, please see [How to get help](setup_instructions#how-to-get-help) for more assistance.
