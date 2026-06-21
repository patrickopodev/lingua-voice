Cost evaluation 

Since you can code yourself, your real costs are just **services and hosting**. Here's the breakdown:

---

## Monthly Cost Estimate

### Free Tier (Launch Phase)

| Service | What it covers | Cost |
|---------|---------------|------|
| Groq API | STT (Whisper) + LLM inference | **Free** (rate limited) |
| edge-tts | Text-to-speech all languages | **Free** |
| Supabase | Database + Auth (500MB, 50k users) | **Free** |
| Render.com | FastAPI backend (with sleep) | **Free** |
| Flutter | App development | **Free** |
| **Total** | | **$0/month** |

**The catch:** Render free tier sleeps after 15 mins of inactivity — first request takes ~30 seconds to wake. Acceptable for testing, bad for real users.

---

### Serious Launch (~100 active users)

| Service | What it covers | Cost |
|---------|---------------|------|
| Render Starter | Always-on FastAPI | **$7/month** |
| Groq API | Likely still free at 100 users | **$0** |
| Supabase | Still free tier | **$0** |
| edge-tts | Free | **$0** |
| **Total** | | **~$7/month** |

---

### Growth Phase (~1,000+ active users)

| Service | Cost |
|---------|------|
| Render (2 instances) | $14/month |
| Groq API (paid tier) | ~$20–40/month |
| Supabase Pro | $25/month |
| **Total** | **~$60–80/month** |

---

## One-Time Costs

| Item | Cost |
|------|------|
| Google Play developer account | **$25** (once) |
| Apple developer account | **$99/year** |
| Domain name (optional) | **~$12/year** |

---

## Honest Assessment

**You can launch for literally $0** and only pay once you have real users. The only unavoidable cost if you want iOS distribution is the **$99/year Apple fee**.

The biggest risk isn't cost — it's Groq's free tier rate limits. At scale, Whisper + LLM per voice message could hit limits fast. But that's a good problem to have.

Want me to map out the Groq rate limits vs. expected usage so you know exactly when you'd need to upgrade?
