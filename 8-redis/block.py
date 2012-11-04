import redis
r=redis.Redis()
while (1):
  comment = r.brpop('comments',0)
  print comment
