tar -cvf secrets.tar ./secrets
gpg --cipher-algo AES256 --symmetric secrets.tar
rm secrets.tar
echo "Secrets encrypted to secrets.tar.gpg"

