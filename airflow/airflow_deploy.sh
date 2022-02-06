#airflow_dags_ssh_key='aws ssm get-parameter --name /github/git-sync-key --with-decryption --query 'Parameter.Value' --output text | base64'
#kubectl create secret generic airflow-git-sync-key --from-file=gitSshKey=/home/ec2-user/environment/git-sync-key --from-file=known_hosts=/home/ec2-user/.ssh/known_hosts --from-file=id_ed25519.pub=/home/ec2-user/environment/git-sync-key.pub -n dev

set -e

function get_ssm_key {
    jq -C --arg PARAMETER_NAME "$1" '[.[]|select(.name==$PARAMETER_NAME)][0] | .value' | xargs echo
}

NAMESPACE='dev'

ssm_credentials=`aws ssm get-parameters \
                    --with-decryption \
                    --names \
                    /airflow/${NAMESPACE}/db/password \
                    /airflow/${NAMESPACE}/db/username \
                    /airflow/${NAMESPACE}/fernet \
                    /airflow/${NAMESPACE}/webserver_secret_key \
                    --query 'Parameters[*].{name:Name,value:Value}'`
airflow_db_username=`echo ${ssm_credentials} | get_ssm_key /airflow/${NAMESPACE}/db/username`
airflow_db_password=`echo ${ssm_credentials} | get_ssm_key /airflow/${NAMESPACE}/db/password`
airflow_fernet_key=`echo ${ssm_credentials} | get_ssm_key /airflow/${NAMESPACE}/fernet`
airflow_webserver_secret_key=`echo ${ssm_credentials} | get_ssm_key /airflow/${NAMESPACE}/webserver_secret_key`
airflow_dags_ssh_key=`aws ssm get-parameter --name /github/git-sync-key --with-decryption --query 'Parameter.Value' --output text | base64`

helm upgrade --install "airflow-configs" ./airflow-helm-configs/ --version 1.4.0 --namespace ${NAMESPACE} \
                        --set db.username=${airflow_db_username} \
                        --set db.password=${airflow_db_password} \
                        --set fernetKey=${airflow_fernet_key} \
                        --set webserverSecretKey=${airflow_webserver_secret_key} \
                        --set gitSshKey='${airflow_dags_ssh_key}' \
                        --values ./airflow-helm-values/values.${NAMESPACE}.yaml
                        
helm upgrade --install "airflow" apache-airflow/airflow --version 1.4.0 --namespace ${NAMESPACE} \
                        --values ./airflow-helm-values/values.${NAMESPACE}.yaml 