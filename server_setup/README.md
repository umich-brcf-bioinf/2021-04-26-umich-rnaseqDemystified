RNA-Seq Demystified Workshop Server Setup
=========================================

Breadcrumb trail for future workshops.

4/23/2021
cgates@umich.edu

- Initial setup
  - See cgates/trsaari for AWS console creds
  - Use this AMI
  - Use this security key (see cgatres/trsaari)
  - Start small
  - Enable ports 22,80
  - Use elastic IP
  - .screenrc
  - If you plan to email from this instance, setup postfix and mutt
    - https://docs.aws.amazon.com/ses/latest/DeveloperGuide/postfix.html
    - See cgates for SMTP creds
    - .muttrc
  - mkdirs and clone repo
    ``` 
    /rsd [drwxr-xr-x] ubuntu root                                          # all shared workshop files in here
    ├── [drwxrwxr-x ubuntu   ubuntu  ]  2021-04-26-umich-rnaseqDemystified # clone of current repo
    ├── [drwxr-xr-x ubuntu   workshop-rsd-users]  conda                    # shared conda environment(s)
    ├── [drwxr-xr-x ubuntu   root    ]  data                               # staged data to be copied to home
    └── [drwxr-x--- ubuntu   ubuntu  ]  participants                       # this may contain user/password and is not world readable
    ```
- Setup shared conda
  - Download Miniconda.sh file

- Setup R
  - mkdir /rsd/R/library
  - Add /usr/local/lib/R/etc/Rprofile.site: .libPaths("/rsd/R/library")
  - launch RStudio and 

- Setup data

- Setup users
  - Extract from eventbrite
  - Create helper users

- Setup R
  - mkdir /rsd/R/library and chmod to a+rw
  - Add /usr/local/lib/R/etc/Rprofile.site: .libPaths("/rsd/R/library")
  - Launch RStudio (http:ip_address), login (as any user) and install required libs ala
    - install.packages('tidyr', lib = '/rsd/R/library')
    - ...
    - BiocManager::install('DESeq2', lib='/rsd/R/library')
    - (etc.)
  - chmod go-w /rsd/R/library
  - Login as different user and test loading libraries installed above
    - Note any sessions started prior to the addition of Rprofile.site above would need to restart their sessions

- Create all users (learners)

- Boost instance
  - A few days before workshop (before emails go out)
  - Size home to 200

- Email users


- Shrink instance

- Shutdown

---
