CATALINA_OPTS=" \
-Xms8g \
-Xmx8g \
-XX:NewSize=3g \
-XX:MaxNewSize=6g \
-XX:PermSize=3g \
-XX:MaxPermSize=6g \
-server \
-Djava.awt.headless=true \
-Dorg.apache.jasper.runtime.BodyContentImpl.LIMIT_BUFFER=true"

export CATALINA_OPTS

