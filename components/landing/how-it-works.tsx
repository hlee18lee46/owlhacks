import { Camera, Activity, Hand, Sparkles } from 'lucide-react'

const steps = [
  {
    icon: Camera,
    title: 'Hold still & smile',
    body: 'Point your front camera at your face in good light. A short scan is all it takes.',
  },
  {
    icon: Activity,
    title: 'Presage reads your vitals',
    body: 'Presage technology picks up tiny changes in your face and chest to estimate heart rate and breathing rate.',
  },
  {
    icon: Hand,
    title: 'Toss your owl',
    body: 'Your results decide which owl you get — smiley, normal, or sad. Flick it across the screen and score.',
  },
  {
    icon: Sparkles,
    title: 'Snap a selfie',
    body: 'Land a smiley owl and it perches right next to you for a selfie worth sharing.',
  },
]

export function HowItWorks() {
  return (
    <section id="how" className="bg-secondary text-secondary-foreground">
      <div className="mx-auto flex max-w-6xl flex-col gap-12 px-5 py-20 md:py-28">
        <div className="flex max-w-2xl flex-col gap-4">
          <p className="font-semibold text-primary">How it works</p>
          <h2 className="text-4xl font-extrabold tracking-tight text-balance md:text-5xl">
            From selfie to scorecard in under a minute.
          </h2>
        </div>
        <ol className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
          {steps.map((step, i) => (
            <li
              key={step.title}
              className="flex flex-col gap-4 rounded-3xl bg-secondary-foreground/5 p-6 ring-1 ring-secondary-foreground/10"
            >
              <div className="flex items-center justify-between">
                <span className="grid size-12 place-items-center rounded-2xl bg-primary text-primary-foreground">
                  <step.icon className="size-6" aria-hidden="true" />
                </span>
                <span className="font-heading text-sm font-semibold text-secondary-foreground/50">
                  Step {i + 1}
                </span>
              </div>
              <h3 className="text-xl font-bold">{step.title}</h3>
              <p className="leading-relaxed text-secondary-foreground/75">
                {step.body}
              </p>
            </li>
          ))}
        </ol>
      </div>
    </section>
  )
}
