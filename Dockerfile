FROM centos as builder

#Dependencies
RUN yum update && yum install -y python java-1.8.0-openjdk-devel curl git zip vim

#Maven install
RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz -o /opt/apache-maven-3.6.0-bin.tar.gz 
RUN tar -xvf /opt/apache-maven-3.6.0-bin.tar.gz -C /opt

#Spark install
RUN curl -fsSL https://archive.apache.org/dist/spark/spark-2.2.1/spark-2.2.1-bin-hadoop2.7.tgz -o /opt/spark-2.2.1-bin-hadoop2.7.tgz
RUN tar -xvf /opt/spark-2.2.1-bin-hadoop2.7.tgz -C /opt

#AWS glue scripts
WORKDIR /opt
RUN git clone https://github.com/awslabs/aws-glue-libs.git

# #Env setup
ENV M2_HOME=/opt/apache-maven-3.6.0 JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64 SPARK_HOME=/opt/spark-2.2.1-bin-hadoop2.7
ENV PATH="${PATH}:${M2_HOME}/bin"

#Run gluepysparksubmit once to download dependent jars
RUN echo "print('Get Dependencies')" > /tmp/maven.py
RUN /opt/aws-glue-libs/bin/gluesparksubmit /tmp/maven.py

# Create final image
FROM centos
RUN yum update && yum install -y python java-1.8.0-openjdk-devel zip
COPY --from=builder /opt/ /opt/
COPY --from=builder /root/.m2/ /root/.m2/
RUN rm -rf /opt/aws-glue-libs/conf

# Wacky workaround to get past issue with p4j error (credit @svajiraya - https://github.com/awslabs/aws-glue-libs/issues/25)
RUN rm -rf /opt/aws-glue-lib/jars/netty*
RUN sed -i /^mvn/s/^/#/ ./bin/glue-setup.sh

# Env VAR setup
ENV M2_HOME=/opt/apache-maven-3.6.0 JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64 SPARK_HOME=/opt/spark-2.2.1-bin-hadoop2.7
ENV PATH="${PATH}:${M2_HOME}/bin"

#Entrypoint for submitting scripts
# ENTRYPOINT ["/opt/aws-glue-libs/bin/gluesparksubmit"]
# CMD []