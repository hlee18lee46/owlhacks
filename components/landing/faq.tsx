import { ChevronDown } from 'lucide-react'

const faqs = [
  {
    q: 'How can a camera measure my heart rate?',
    a: 'What the Hoot uses Presage technology, which analyzes subtle changes in your face and upper body in the camera feed to estimate heart rate and breathing rate — no wearable required.',
  },
  {
    q: 'What do I need to get an accurate reading?',
    a: 'Good, even lighting, your face clearly in frame, and staying still for the short scan. Avoid backlight and heavy movement.',
  },
  {
    q: 'Is What the Hoot a medical device?',
    a: 'No. What the Hoot is a wellness and fun app. It is not intended to diagnose, treat, or prevent any condition. If you have health concerns, talk to a medical professional.',
  },
  {
    q: 'Which devices are supported?',
    a: 'What the Hoot is available for iPhone. Download it from the App Store to get started.',
  },
]

export function Faq() {
  return (
    <section id="faq" className="mx-auto max-w-3xl px-5 py-20 md:py-28">
      <h2 className="text-center text-4xl font-extrabold tracking-tight text-balance md:text-5xl">
        Questions? We&apos;ve got hoots.
      </h2>
      <div className="mt-10 flex flex-col gap-3">
        {faqs.map((item) => (
          <details
            key={item.q}
            className="group rounded-2xl bg-card p-5 ring-1 ring-border open:ring-2 open:ring-primary"
          >
            <summary className="flex cursor-pointer list-none items-center justify-between gap-4 font-heading text-lg font-bold [&::-webkit-details-marker]:hidden">
              {item.q}
              <ChevronDown
                className="size-5 shrink-0 transition-transform group-open:rotate-180"
                aria-hidden="true"
              />
            </summary>
            <p className="mt-3 leading-relaxed text-muted-foreground">
              {item.a}
            </p>
          </details>
        ))}
      </div>
    </section>
  )
}
