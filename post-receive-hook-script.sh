#!/bin/bash 

WEB_FOLDER="/var/www/domain.com"
REPO_FOLDER="/var/repo/site.git"
HOOKS_FOLDER="$REPO_FOLDER/hooks"

echo "Creating Directories..."

sudo mkdir -p "$WEB_FOLDER" "$REPO_FOLDER"

sudo chown -R ubuntu:ubuntu /var/repo/site.git

echo "Directories Successfully Created"

echo "Creating Repository on site.git..."

cd /var/repo/site.git

sudo git init --bare
echo "Repository created Successfully"

echo "Configuring post-receive hook..."

sudo mkdir -p "$HOOKS_FOLDER"

sudo tee "$HOOKS_FOLDER/post-receive" > /dev/null <<EOF
#!/bin/sh
sudo git --work-tree=$WEB_FOLDER --git-dir=$REPO_FOLDER checkout -f >> /tmp/hook.log 2>&1
echo "Files updated in $WEB_FOLDER" >> /tmp/hook.log
cd "$WEB_FOLDER/my-react-app"
sudo -u ubuntu docker --version >> /tmp/hook.log
export PATH=$PATH:/usr/bin
sudo -u ubuntu docker stop -f react-container  >> /tmp/hook.log 2>&1 &
sudo -u ubuntu docker rm -f react-container >> /tmp/hook.log 2>&1 &
sudo -u ubuntu docker build -t my-react-app .
sudo -u ubuntu docker run -d -p 3000:3000 --name react-container  my-react-app >> /tmp/hook.log 2>&1 &
EOF

sudo chmod +x "$HOOKS_FOLDER/post-receive"

echo "Post Receive Hook configured as expected"