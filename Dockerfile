FROM rockylinux:9

LABEL maintainer="toriqnain@gmail.com"

# Install the web server + tools needed to extract the template
RUN yum install -y httpd \
    zip \
    unzip \
    && yum clean all

# Grab the static template (Loxury) from free-css.com
ADD https://www.free-css.com/assets/files/free-css-templates/download/page258/loxury.zip /var/www/html/

WORKDIR /var/www/html

# Extract, move contents to the html root, then clean up unused files
RUN unzip loxury.zip \
    && cp -rvf loxury/* . \
    && rm -rf loxury loxury.zip

EXPOSE 80

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
