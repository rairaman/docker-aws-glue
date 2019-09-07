FROM ubuntu

#Dependencies
RUN apt update && apt install -y python3-minimal default-jdk curl git zip vim

#Maven install
RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz -o /opt/apache-maven-3.6.0-bin.tar.gz 
RUN tar -xvf /opt/apache-maven-3.6.0-bin.tar.gz -C /opt

#Spark install
RUN curl -fsSL https://archive.apache.org/dist/spark/spark-2.2.1/spark-2.2.1-bin-hadoop2.7.tgz -o /opt/spark-2.2.1-bin-hadoop2.7.tgz
RUN tar -xvf /opt/spark-2.2.1-bin-hadoop2.7.tgz -C /opt

#AWS glue scripts
WORKDIR /opt
RUN git clone https://github.com/awslabs/aws-glue-libs.git

#Env setup
ENV M2_HOME=/opt/apache-maven-3.6.0 JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 SPARK_HOME=/opt/spark-2.2.1-bin-hadoop2.7
ENV PATH="${PATH}:${M2_HOME}/bin:${SPARK_HOME}/bin:/opt/aws-glue-libs/bin"
RUN ln -s /usr/bin/python3 /usr/bin/python

#Run gluepysparksubmit once to download dependent jars
RUN echo "print('Get Dependencies')" > /tmp/maven.py
RUN /opt/aws-glue-libs/bin/gluesparksubmit /tmp/maven.py

#Entrypoint for submitting scripts
ENTRYPOINT ["/opt/aws-glue-libs/bin/gluesparksubmit"]
CMD []