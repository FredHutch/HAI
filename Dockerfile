FROM fredhutch/r-shiny-server-base:4.2.0
RUN apt-get update -y && apt-get install -y pandoc libglpk-dev apt-transport-https
RUN mkdir -p /etc/apt/keyrings
RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc
RUN echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
RUN apt-get update -y
RUN apt-get install -y temurin-17-jdk
RUN R -q -e 'install.packages("BiocManager", repos="http://cran.rstudio.com/")'
RUN R -q -e 'BiocManager::install(c("rJava"))'
RUN LD_LIBRARY_PATH=/usr/lib/jvm/temurin-17-jdk-amd64/lib/server/ R CMD javareconf
RUN R -q -e 'BiocManager::install(c("shinythemes", "data.table",  "RCurl", "DT", "shinyjs", "shiny", "stringdist", "irr", "limma", "pbapply", "parallelDist", "mgcv", "psych", "RColorBrewer", "dplyr", "devtools", "ROR", "xlsx", "igraph", "ips"))'


RUN rm -rf /srv/shiny-server/
ADD ./ /srv/shiny-server/


EXPOSE 3838
EXPOSE 8888

WORKDIR /srv/shiny-server/

CMD R -f app.R

