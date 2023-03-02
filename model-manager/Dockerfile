FROM --platform=linux/x86_64  python:3.9-alpine 
RUN make 
RUN mkdir /app 
WORKDIR /app 
COPY . /app 
EXPOSE 3000 
CMD ["python"]