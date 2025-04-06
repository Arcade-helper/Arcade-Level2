export ZONE=

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

BUCKET_NAME="${PROJECT_ID}-bucket"

if gsutil ls -b "gs://${BUCKET_NAME}" >/dev/null 2>&1; then
    echo "${YELLOW_TEXT}${BOLD_TEXT}Bucket '${BUCKET_NAME}' already exists.${RESET_FORMAT}"
else

    echo "${BLUE_TEXT}${BOLD_TEXT}Creating Cloud Storage bucket: ${BUCKET_NAME}${RESET_FORMAT}"
    if gcloud storage buckets create "gs://${BUCKET_NAME}" --location=US --uniform-bucket-level-access; then
        echo "${GREEN_TEXT}${BOLD_TEXT}Bucket '${BUCKET_NAME}' created successfully.${RESET_FORMAT}"
    else
        echo "${RED_TEXT}${BOLD_TEXT}Failed to create bucket '${BUCKET_NAME}'. Check your permissions and try again.${RESET_FORMAT}"
        exit 1
    fi
fi

gcloud compute instances create my-instance \
    --machine-type=e2-medium \
    --zone=$ZONE \
    --image-project=debian-cloud \
    --image-family=debian-11 \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-balanced \
    --create-disk=size=100GB,type=pd-standard,mode=rw,device-name=additional-disk \
    --tags=http-server

    gcloud compute disks create mydisk \
    --size=200GB \
    --zone=$ZONE

gcloud compute instances attach-disk my-instance \
    --disk=mydisk \
    --zone=$ZONE

sleep 20

cat > prepare_disk.sh <<'EOF_END'

sudo apt update
sudo apt install nginx -y
sudo systemctl start nginx

EOF_END

gcloud compute scp prepare_disk.sh my-instance:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet

gcloud compute ssh my-instance --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet --command="bash /tmp/prepare_disk.sh"

