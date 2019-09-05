FROM imhshekhar47/centos-jre8:latest 

LABEL "author"="Himanshu Shekhar <himanshu.shekhar.in@gmail.com>"

ADD --chown=deployer:deployer app/ /home/deployer/app/

USER ${UNAME}
WORKDIR /home/${UNAME}

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["java -jar /home/deployer/app/kafka-mock-producer-0.1.0.jar"]