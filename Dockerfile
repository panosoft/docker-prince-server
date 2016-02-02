FROM debian:jessie

# Install utilities
RUN apt-get update && apt-get install --assume-yes \
    wget \
    git \
    make \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Enable contrib repository
RUN sed -i 's/$/ contrib/' /etc/apt/sources.list

# Install fonts
# NOTE: must remove bitmap-fonts.conf due to fontconfig bug
RUN apt-get update && apt-get install --assume-yes \
    fontconfig \
    msttcorefonts \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm /etc/fonts/conf.d/10-scale-bitmap-fonts.conf

# Install PrinceXML
ENV PRINCE=prince-9.0r5-linux-amd64-static
ENV PRINCE_TAR=$PRINCE.tar.gz
RUN wget http://www.princexml.com/download/$PRINCE_TAR \
  && tar -xzf $PRINCE_TAR \
  && rm $PRINCE_TAR \
  && cd $PRINCE \
  && ./install.sh \
  && cd .. \
  && rm -r $PRINCE

# Install node
RUN git clone https://github.com/tj/n.git n \
  && cd n \
  && make install \
  && n 4.*

# Install @panosoft/prince-server
RUN npm install -g @panosoft/prince-server@"^0.1.0"

EXPOSE 8443

CMD ["prince-server", "--key", "/credentials/server.key", "--cert", "/credentials/server.crt", "--port", "8443"]
