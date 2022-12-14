FROM ubuntu:20.04

MAINTAINER yuhao<yqyuhao@outlook.com>

RUN sed -i 's/http:\/\/archive\.ubuntu\.com\/ubuntu\//http:\/\/mirrors\.aliyun\.com\/ubuntu\//g' /etc/apt/sources.list

# set timezone
RUN set -x \
&& export DEBIAN_FRONTEND=noninteractive \
&& apt-get update \
&& apt-get install -y tzdata \
&& ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime \
&& echo "Asia/Shanghai" > /etc/timezone

# install packages
RUN apt-get update \

&& apt-get install -y less curl apt-utils vim wget gcc-7 g++-7 make cmake git unzip dos2unix libncurses5 \

# lib
&& apt-get install -y zlib1g-dev libjpeg-dev libncurses5-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev \
 
# python3 perl java r-base
&& apt-get install -y python3 python3-dev python3-pip python perl openjdk-8-jdk r-base r-base-dev bc

ENV software /Righton_software

# create software folder

RUN mkdir -p /data/RightonAuto/analysis /data/RightonAuto/results $software/database $software/source $software/target $software/bin

# fastp v0.22.0
WORKDIR $software/source
RUN wget -c https://github.com/OpenGene/fastp/archive/refs/tags/v0.22.0.tar.gz -O $software/source/fastp.v0.22.0.tar.gz \
&& tar -xf $software/source/fastp.v0.22.0.tar.gz && cd $software/source/fastp-0.22.0 && make \
&& ln -s $software/source/fastp-0.22.0/fastp $software/bin/fastp

# bwa v0.7.17
WORKDIR $software/source
RUN wget -c https://github.com/lh3/bwa/releases/download/v0.7.17/bwa-0.7.17.tar.bz2 -O $software/source/bwa-0.7.17.tar.bz2 \
&& tar -xjvf $software/source/bwa-0.7.17.tar.bz2 && cd $software/source/bwa-0.7.17 \
&& make && ln -s $software/source/bwa-0.7.17/bwa $software/bin/bwa

# samtools v1.11
WORKDIR $software/source
RUN wget -c https://github.com/samtools/samtools/releases/download/1.11/samtools-1.11.tar.bz2 -O $software/source/samtools-1.11.tar.bz2 \
&& tar jxvf $software/source/samtools-1.11.tar.bz2 \
&& cd $software/source/samtools-1.11 \
&& ./configure \
&& make \
&& ln -s $software/source/samtools-1.11/samtools $software/bin/samtools

# gatk 4.1.3.0
WORKDIR $software/source
RUN wget -c https://github.com/broadinstitute/gatk/releases/download/4.1.3.0/gatk-4.1.3.0.zip \
&& unzip gatk-4.1.3.0.zip \
&& ln -s $software/source/gatk-4.1.3.0/gatk $software/bin/gatk

# bedtools v2.29.2
WORKDIR $software/source
RUN wget -c https://github.com/arq5x/bedtools2/releases/download/v2.29.2/bedtools-2.29.2.tar.gz -O $software/source/bedtools-2.29.2.tar.gz \
&& tar -zxvf $software/source/bedtools-2.29.2.tar.gz && mv $software/source/bedtools2 $software/source/bedtools-2.29.2 \
&& cd $software/source/bedtools-2.29.2/ \
&& sed -i '112s/const/constexpr/g' src/utils/fileType/FileRecordTypeChecker.h \
&& make clean \
&& make all \
&& ln -s $software/source/bedtools-2.29.2/bin/bedtools $software/bin/bedtools

# lianti r142
WORKDIR $software/source
RUN git clone https://github.com/lh3/lianti.git \
&& mv $software/source/lianti $software/source/lianti-r142 && cd $software/source/lianti-r142 && make \
&& ln -s $software/source/lianti-r142/lianti $software/bin/lianti

# fastqc v0.11.9
WORKDIR $software/source
RUN wget -c https://github.com/s-andrews/FastQC/archive/refs/tags/v0.11.9.tar.gz -O $software/source/fastqc.v0.11.9.tar.gz \
&& tar -xf $software/source/fastqc.v0.11.9.tar.gz \
&& cd $software/source/FastQC-0.11.9 \
&& ln -s $software/source/FastQC-0.11.9/fastqc $software/bin/fastqc

# snpEff_v4_3t
WORKDIR $software/source
RUN wget -c https://nchc.dl.sourceforge.net/project/snpeff/snpEff_v4_3t_core.zip -O $software/source/snpEff_v4_3t_core.zip \
&& unzip $software/source/snpEff_v4_3t_core.zip && mv $software/source/snpEff $software/source/snpEff_v4_3t \
&& sed -i '17s#\.\/#/Righton_software/database/snpEff_hg19/#g' $software/source/snpEff_v4_3t/snpEff.config \
&& ln -s $software/source/snpEff_v4_3t $software/bin/snpEff

# genefuse v0.6.1
WORKDIR $software/source
RUN wget https://github.com/OpenGene/GeneFuse/archive/refs/tags/v0.6.1.tar.gz -O $software/source/genefuse-v0.6.1.tar.gz \
&& tar -zxvf $software/source/genefuse-v0.6.1.tar.gz \
&& cd $software/source/GeneFuse-0.6.1 && make \
&& ln -s $software/source/GeneFuse-0.6.1 $software/bin/genefuse

# pindel 0.2.5b9
WORKDIR $software/source
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.12.0-Linux-x86_64.sh -O $software/source/Miniconda3-py37_4.12.0-Linux-x86_64.sh \
&& sh $software/source/Miniconda3-py37_4.12.0-Linux-x86_64.sh -b -p $software/bin/conda-v4.12 \
&& $software/bin/conda-v4.12/bin/conda config --add channels conda-forge \
&& $software/bin/conda-v4.12/bin/conda config --add channels r \
&& $software/bin/conda-v4.12/bin/conda config --add channels bioconda \
&& $software/bin/conda-v4.12/bin/conda install -y pindel -c bioconda

# cnvkit v0.9.9
WORKDIR $software/source
RUN $software/bin/conda-v4.12/bin/conda install -y cnvkit -c bioconda

# jellyfish
RUN $software/bin/conda-v4.12/bin/conda install -y jellyfish -c bioconda

# ncbi-blast
RUN $software/bin/conda-v4.12/bin/conda install -y blast -c bioconda

# km
WORKDIR $software/source
RUN $software/bin/conda-v4.12/bin/pip3 install km-walk \
&& ln -s $software/bin/conda-v4.12/bin/km $software/bin/km

# Annovar 2017-07-17
WORKDIR $software/source
RUN git clone https://github.com/yqyuhao/righton_service.git && cd righton_service && unzip annovar_2017-07-17.zip && cd annovar && cp *.pl $software/bin

# IGVtools v2.3.95
WORKDIR $software/source
RUN wget https://data.broadinstitute.org/igv/projects/downloads/2.3/igvtools_2.3.95.zip -O $software/source/igvtools_2.3.95.zip \
&& unzip igvtools_2.3.95.zip && ln -s $software/source/IGVTools $software/bin/IGVTools

# bcftools v1.8
WORKDIR $software/source
RUN wget https://github.com/samtools/bcftools/releases/download/1.8/bcftools-1.8.tar.bz2 -O $software/source/bcftools-1.8.tar.bz2 \
&& tar xjvf $software/source/bcftools-1.8.tar.bz2 \
&& cd $software/source/bcftools-1.8 && ./configure && make \
&& ln -s $software/source/bcftools-1.8/bcftools $software/bin/bcftools

# delly v0.8.7
WORKDIR $software/source
RUN wget https://github.com/dellytools/delly/releases/download/v0.8.7/delly_v0.8.7_linux_x86_64bit -O $software/source/delly \
&& chmod 755 $software/source/delly \
&& ln -s $software/source/delly $software/bin/delly

# msisensor_pro
WORKDIR $software/source
RUN apt install -y libhts-dev && git clone https://github.com/xjtu-omics/msisensor-pro.git \
&& ln -s $software/source/msisensor-pro $software/bin/msisensor-pro

# R dplyr 
RUN Rscript -e "install.packages(c('tidyr','dplyr'))"

# copy esssential files
WORKDIR $software/source
RUN cd righton_service && cp -f fastq2stat.pl capture_analysis_auto capture_filter_auto capture_filter_auto_wes drug_split msisensor_pro tmb_filter PCR_analysis_auto pcr_filter_auto drug_split msisensor_pro tmb_filter unique_panel.R $software/bin/

WORKDIR $software/source
RUN cd righton_service && cp A387V2_20220713.bed A215V1-20201023.bed Righton_Drug_Site_hg19.database probe.bed fusion_related.bed $software/target/

# install essential packages
WORKDIR $software/source

# chown root:root
WORKDIR $software/source
RUN chown root:root -R $software/source

# mkdir fastq directory and analysis directory
WORKDIR /data/RightonAuto/analysis
