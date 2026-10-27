
FROM busybox:1.36

RUN echo "CKS process test" > /tmp/testfile

CMD ["/bin/sh", "-c", "while true; do cat /tmp/testfile >/dev/null; sleep 1; done"]
