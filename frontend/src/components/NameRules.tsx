const rules = [
  {
    icon: '📏',
    title: '3–32 Characters',
    desc: 'Pick something memorable',
  },
  {
    icon: '🔡',
    title: 'Lowercase Only',
    desc: 'Letters a-z, numbers 0-9',
  },
  {
    icon: '➖',
    title: 'Hyphens Allowed',
    desc: 'Use hyphens to separate words',
  },
  {
    icon: '🎨',
    title: 'Unique Generative Art',
    desc: 'Your wallet creates the art',
  },
  {
    icon: '⛓️',
    title: '100% On-Chain',
    desc: 'SVG art stored on the blockchain',
  },
  {
    icon: '♾️',
    title: 'Yours Forever',
    desc: 'No renewals, no expiry',
  },
];

export function NameRules() {
  return (
    <section id="rules" className="py-20 px-4">
      <div className="max-w-4xl mx-auto">
        <div className="text-center mb-12">
          <h2 className="text-3xl sm:text-4xl font-bold mb-3">
            How it works
          </h2>
          <p className="text-gray-400 text-lg">
            Simple rules, powerful identity
          </p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {rules.map((rule) => (
            <div
              key={rule.title}
              className="glass-card p-5 hover:border-claw-purple/30 transition-all duration-300 group"
            >
              <div className="text-2xl mb-3 group-hover:scale-110 transition-transform duration-300">
                {rule.icon}
              </div>
              <h3 className="font-semibold text-white mb-1">{rule.title}</h3>
              <p className="text-gray-500 text-sm">{rule.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
