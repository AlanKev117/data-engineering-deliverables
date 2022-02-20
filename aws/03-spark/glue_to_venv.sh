#!/bin/zsh

# Exit in case of errors
set -e

# Check that Python virtual environment is active
[ -n "${VIRTUAL_ENV:+kudos}" ] || {echo "Virtual environment is not active" && exit 1}

# URIs where both Glue's Maven and Spark are housed.
GLUE_MAVEN_URI=https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-common/apache-maven-3.6.0-bin.tar.gz
GLUE_SPARK_URI=https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-3.0/spark-3.1.1-amzn-0-bin-3.2.1-amzn-3.tgz

# Assert installation dir. exists in venv dir.
INSTALL_DIR=$VIRTUAL_ENV/opt
[ -d $INSTALL_DIR ] || mkdir -p $INSTALL_DIR


install_maven () {
    echo "Installing AWS Glue Maven"
        
    echo "Downloading Maven from $GLUE_MAVEN_URI"
    MAVEN_FILE=$(echo $GLUE_MAVEN_URI | rev | cut -d"/" -f1 | rev)
    wget -O $MAVEN_FILE $GLUE_MAVEN_URI
    
    echo "Extracting Maven"
    MAVEN_DIR=$(tar -tzf $MAVEN_FILE | head -1 | cut -d"/" -f1)
    [ ! -d $INSTALL_DIR/$MAVEN_DIR ] || rm -rf $INSTALL_DIR/$MAVEN_DIR
    tar -xzvf $MAVEN_FILE -C $INSTALL_DIR

    echo "Deleting temp. files"
    rm $MAVEN_FILE

    MAVEN_HOME=$INSTALL_DIR/$MAVEN_DIR
    echo "maven home: $MAVEN_HOME"
}

install_spark () {
    echo "Installing AWS Glue Spark"

    echo "Downloading Spark"
    SPARK_FILE=$(echo $GLUE_SPARK_URI | rev | cut -d"/" -f1 | rev)
    wget -O $SPARK_FILE $GLUE_SPARK_URI
    
    echo "Extracting spark"
    SPARK_DIR=$(tar -tzf $SPARK_FILE | head -1 | cut -f1 -d"/")
    [ ! -d $INSTALL_DIR/$SPARK_DIR ] || rm -rf $INSTALL_DIR/$SPARK_DIR
    tar -xzvf $SPARK_FILE -C $INSTALL_DIR

    echo "Deleting temp. files"
    rm $SPARK_FILE

    SPARK_HOME=$INSTALL_DIR/$SPARK_DIR
    echo "spark home: $SPARK_HOME"
}

persist_glue_vars () {
    echo "Saving Spark vars and path update"
    
    # Truncate glue.env file if already existed.
    GLUE_ENV=$VIRTUAL_ENV/glue.env
    [ -f $GLUE_ENV ] && : > $GLUE_ENV
    
    echo "export MAVEN_HOME=$MAVEN_HOME" >> $GLUE_ENV
    echo "export SPARK_HOME=$SPARK_HOME" >> $GLUE_ENV
    echo 'export PATH=$MAVEN_HOME/bin:$SPARK_HOME/bin:$PATH' >> $GLUE_ENV
    
    PURPLE="\033[0;35m"
    echo "\nAmazon Glue Maven and Spark dependencies installed in your enviroment\!"
    echo "To enable them run:\n"
    echo "\t${PURPLE}source \$VIRTUAL_ENV/glue.env\n"
}

install_maven
install_spark
persist_glue_vars