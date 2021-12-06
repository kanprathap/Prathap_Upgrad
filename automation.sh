#!/bin/sh
  
#variable init

myname=Prathap

timestamp=$(date "+%d%m%Y-%H%M%S")

#Check for Service running

ps auxw | grep apache2 | grep -v grep > /dev/null
if [ $? != 0 ]
then
        /etc/init.d/apache2 start > /dev/null
fi


# Create Tar file 
filename="$myname-httpd-logs-$timestamp.tar"
#tar -zcvf /home/ubuntu/temp/"$myname-httpd-logs-$timestamp.tar" -P /var/log/apache2/*.log
tar -zcvf /home/ubuntu/temp/$filename -P /var/log/apache2/*.log

#Copy to S3
aws s3 cp /home/ubuntu/temp/$filename s3://upgrad-prathap/$filename


filesize=$(wc -c /home/ubuntu/temp/$filename | awk '{print $1}')

###
FILE=/var/www/html/inventory.html
if test -f "$FILE"; then
    echo "$FILE exists."
else
    sudo cp inventory_template.html /var/www/html/inventory.html
fi

echo "      <tr>\n         <td>httpd-logs</td>\n         <td>$timestamp</td>\n         <td>tar</td>\n         <td>$filesize</td>\n       </tr>\n       </table>" > temp.txt

sudo sed -i '/<\/table>/{
    s/<\/table>//g
    r temp.txt
}' /var/www/html/inventory.html
############

rm temp.txt
rm /home/ubuntu/temp/$filename