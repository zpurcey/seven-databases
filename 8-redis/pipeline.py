import redis
r=redis.Redis()
pipe = r.pipeline()
pipe.set('prag','http://pragprog.com').incr('count')
pipe.execute()
