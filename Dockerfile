FROM fredhutch/r-shiny-server-base:4.2.0
RUN apt-get update -y && apt-get install -y pandoc libglpk-dev
RUN R -q -e 'install.packages("BiocManager", repos="http://cran.rstudio.com/")'
RUN R -q -e 'BiocManager::install(c("shinythemes", "data.table",  "RCurl", "DT", "shinyjs", "shiny", "stringdist", "irr", "limma", "pbapply", "parallelDist", "mgcv", "psych", "RColorBrewer", "dplyr", "devtools", "ROR", "xlsx", "igraph", "ips"))'


RUN rm -rf /srv/shiny-server/
ADD ./ /srv/shiny-server/


EXPOSE 3838
EXPOSE 8888

WORKDIR /srv/shiny-server/

CMD R -f app.R

