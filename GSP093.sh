gcloud auth list

gcloud config list project

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

gcloud compute instances create arcadehelper --project=$DEVSHELL_PROJECT_ID --zone $ZONE --machine-type=e2-medium --create-disk=auto-delete=yes,boot=yes,device-name=arcadecrew,image=projects/windows-cloud/global/images/windows-server-2022-dc-v20230913,mode=rw,size=50,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced



gcloud compute instances get-serial-port-output arcadehelper --zone=$ZONE


gcloud compute reset-windows-password arcadehelper --zone $ZONE --user admin --quiet
