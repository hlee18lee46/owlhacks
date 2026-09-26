import Image from 'next/image'
import { Check } from 'lucide-react'

const perks = [
  'Your smiley owl perches right beside you',
  'Save to Photos or share in one tap',
  'A little reward for a good day',
]

export function SelfieSection() {
  return (
    <section id="selfie" className="bg-sky">
      <div className="mx-auto grid max-w-6xl items-center gap-12 px-5 py-20 md:grid-cols-2 md:py-28">
        <div className="relative mx-auto aspect-[4/5] w-full max-w-md overflow-hidden rounded-[2.5rem] border-8 border-card shadow-2xl md:order-2 md:rotate-2">
          <Image
            src="/selfie.png"
            alt="Selfie of a smiling person posing with the Smiley Owl"
            fill
            sizes="(min-width: 768px) 448px, 90vw"
            className="object-cover"
          />
        </div>
        <div className="flex flex-col gap-6 text-sky-foreground">
          <p className="font-semibold">The grand finale</p>
          <h2 className="text-4xl font-extrabold tracking-tight text-balance md:text-5xl">
            Land a smiley owl. Earn the selfie.
          </h2>
          <p className="max-w-md text-lg leading-relaxed">
            When your vitals come back happy, the Smiley Owl sticks around
            for a photo. It&apos;s the best kind of proof you took a minute
            for yourself.
          </p>
          <ul className="flex flex-col gap-3">
            {perks.map((perk) => (
              <li key={perk} className="flex items-center gap-3 font-medium">
                <span className="grid size-7 shrink-0 place-items-center rounded-full bg-secondary text-secondary-foreground">
                  <Check className="size-4" aria-hidden="true" />
                </span>
                {perk}
              </li>
            ))}
          </ul>
        </div>
      </div>
    </section>
  )
}
