import Image from 'next/image'
import { cn } from '@/lib/utils'

const owls = [
  {
    src: '/owls/happy.png',
    name: 'Smiley Owl',
    tag: 'Feeling great',
    body: 'Calm heart, steady breath. Toss it high — and unlock the owl selfie.',
    tagClass: 'bg-primary text-primary-foreground',
    featured: true,
  },
  {
    src: '/owls/normal.png',
    name: 'Normal Owl',
    tag: 'Doing okay',
    body: 'Nothing to worry about. A solid, everyday hoot. Keep it up.',
    tagClass: 'bg-sky text-sky-foreground',
    featured: false,
  },
  {
    src: '/owls/sad.png',
    name: 'Sad Owl',
    tag: 'Take a breather',
    body: 'Readings look a little elevated. Slow down, breathe, and try again later.',
    tagClass: 'bg-accent text-accent-foreground',
    featured: false,
  },
]

export function OwlMoods() {
  return (
    <section id="owls" className="mx-auto max-w-6xl px-5 py-20 md:py-28">
      <div className="flex flex-col items-start justify-between gap-6 md:flex-row md:items-end">
        <div className="flex max-w-xl flex-col gap-4">
          <p className="font-semibold text-accent">Meet the owls</p>
          <h2 className="text-4xl font-extrabold tracking-tight text-balance md:text-5xl">
            Three owls. One honest read on how you&apos;re doing.
          </h2>
        </div>
        <p className="max-w-sm leading-relaxed text-muted-foreground">
          Numbers are useful, but an owl&apos;s face says it faster. Every scan
          hands you an owl to throw — which one depends on you.
        </p>
      </div>

      <ul className="mt-12 grid gap-6 md:grid-cols-3">
        {owls.map((owl) => (
          <li
            key={owl.name}
            className={cn(
              'group flex flex-col overflow-hidden rounded-3xl bg-card ring-1 ring-border',
              owl.featured && 'ring-4 ring-primary',
            )}
          >
            <div className="relative aspect-square overflow-hidden bg-sky">
              <Image
                src={owl.src}
                alt={`${owl.name} mascot`}
                fill
                sizes="(min-width: 768px) 33vw, 100vw"
                className={cn(
                  'object-cover transition-transform duration-500 group-hover:scale-105',
                  owl.featured && 'animate-owl-toss',
                )}
              />
            </div>
            <div className="flex flex-col gap-3 p-6">
              <span
                className={cn(
                  'w-fit rounded-full px-3 py-1 text-xs font-bold',
                  owl.tagClass,
                )}
              >
                {owl.tag}
              </span>
              <h3 className="text-2xl font-bold">{owl.name}</h3>
              <p className="leading-relaxed text-muted-foreground">
                {owl.body}
              </p>
            </div>
          </li>
        ))}
      </ul>
    </section>
  )
}
