import Image from 'next/image'
import { Heart, Wind } from 'lucide-react'
import { AppStoreButton } from './app-store-button'

export function Hero() {
  return (
    <section
      id="top"
      className="mx-auto grid max-w-6xl items-center gap-14 px-5 pt-12 pb-20 md:grid-cols-2 md:pt-20 md:pb-28"
    >
      <div className="flex flex-col items-start gap-7">
        <p className="rounded-full bg-sky px-3 py-1 text-sm font-semibold text-sky-foreground">
          Camera-powered vitals for iPhone
        </p>
        <h1 className="text-5xl font-extrabold leading-[1.02] tracking-tight text-balance md:text-7xl">
          Look at your phone. Find out how you&apos;re{' '}
          <span className="text-primary [-webkit-text-stroke:1.5px_var(--foreground)]">
            hooting
          </span>
          .
        </h1>
        <p className="max-w-md text-lg leading-relaxed text-muted-foreground text-pretty">
          What the Hoot reads your heart rate and breathing rate from a short
          selfie video — no straps, no wearables. Then your owl shows up to
          tell you how it went.
        </p>
        <div className="flex flex-wrap items-center gap-4">
          <AppStoreButton />
          <a
            href="#how"
            className="font-semibold underline decoration-primary decoration-4 underline-offset-8 hover:decoration-accent"
          >
            See how it works
          </a>
        </div>
      </div>

      <div className="relative mx-auto w-full max-w-sm">
        <div className="relative aspect-[9/19] overflow-hidden rounded-[3rem] border-[10px] border-secondary bg-secondary shadow-2xl">
          <Image
            src="/selfie.png"
            alt="A person taking a selfie in the What the Hoot app with a happy owl on her shoulder"
            fill
            priority
            sizes="(min-width: 768px) 384px, 90vw"
            className="object-cover"
          />
          <div
            aria-hidden="true"
            className="animate-scan absolute inset-x-6 h-0.5 rounded-full bg-primary shadow-[0_0_16px_4px_var(--primary)]"
          />
          <div className="absolute inset-x-0 top-0 flex justify-center pt-3">
            <span className="h-6 w-24 rounded-full bg-secondary" />
          </div>
        </div>

        <div className="absolute -left-2 top-24 flex items-center gap-3 rounded-2xl bg-card px-4 py-3 shadow-lg md:-left-14">
          <span className="grid size-9 place-items-center rounded-full bg-accent text-accent-foreground">
            <Heart className="animate-heartbeat size-5" fill="currentColor" />
          </span>
          <span className="flex flex-col leading-tight">
            <span className="text-xs text-muted-foreground">Heart rate</span>
            <span className="font-heading text-xl font-bold">
              72 <span className="text-sm font-medium">bpm</span>
            </span>
          </span>
        </div>

        <div className="absolute -right-2 top-1/2 flex items-center gap-3 rounded-2xl bg-card px-4 py-3 shadow-lg md:-right-12">
          <span className="grid size-9 place-items-center rounded-full bg-sky text-sky-foreground">
            <Wind className="animate-breathe size-5" />
          </span>
          <span className="flex flex-col leading-tight">
            <span className="text-xs text-muted-foreground">Breathing</span>
            <span className="font-heading text-xl font-bold">
              14 <span className="text-sm font-medium">/ min</span>
            </span>
          </span>
        </div>

        <div className="absolute -bottom-6 -left-2 flex items-center gap-2 rounded-full bg-primary py-1 pr-4 pl-1 font-heading font-bold text-primary-foreground shadow-lg md:-left-10">
          <span className="relative size-11 overflow-hidden rounded-full bg-sky">
            <Image
              src="/owls/happy.png"
              alt=""
              fill
              sizes="44px"
              className="scale-[1.9] object-cover"
            />
          </span>
          Happy hoot!
        </div>
      </div>
    </section>
  )
}
