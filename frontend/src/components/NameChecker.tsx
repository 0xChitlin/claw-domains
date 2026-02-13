import { useState, useEffect, useCallback } from 'react';
import { useIsAvailable } from '../hooks/useClawContract';

function validateName(name: string): string | null {
  if (name.length === 0) return null;
  if (name.length < 3) return 'Name must be at least 3 characters';
  if (name.length > 32) return 'Name must be 32 characters or less';
  if (!/^[a-z0-9-]+$/.test(name)) return 'Only lowercase letters, numbers, and hyphens';
  return null;
}

interface NameCheckerProps {
  onNameValid: (name: string, available: boolean) => void;
}

export function NameChecker({ onNameValid }: NameCheckerProps) {
  const [input, setInput] = useState('');
  const [debouncedName, setDebouncedName] = useState('');

  // Debounce input
  useEffect(() => {
    const timer = setTimeout(() => {
      const clean = input.toLowerCase().trim();
      setDebouncedName(clean);
    }, 400);
    return () => clearTimeout(timer);
  }, [input]);

  const validationError = validateName(debouncedName);
  const canCheck = debouncedName.length >= 3 && !validationError;

  const { data: isAvailable, isLoading, isFetching } = useIsAvailable(canCheck ? debouncedName : '');

  const handleChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value.toLowerCase().replace(/[^a-z0-9-]/g, '');
    setInput(val);
  }, []);

  // Notify parent of availability
  useEffect(() => {
    if (canCheck && isAvailable !== undefined) {
      onNameValid(debouncedName, isAvailable);
    }
  }, [canCheck, debouncedName, isAvailable, onNameValid]);

  const showStatus = debouncedName.length > 0;
  const checking = isLoading || isFetching;

  return (
    <div className="w-full max-w-xl mx-auto">
      <div className="relative">
        <input
          type="text"
          value={input}
          onChange={handleChange}
          placeholder="Search for a name..."
          maxLength={32}
          className="w-full h-14 pl-5 pr-32 rounded-xl bg-claw-card border border-claw-border text-white text-lg font-mono placeholder:text-gray-600 focus:outline-none focus:border-claw-purple/50 focus:ring-1 focus:ring-claw-purple/30 transition-all"
          autoComplete="off"
          spellCheck={false}
        />
        <div className="absolute right-3 top-1/2 -translate-y-1/2 flex items-center gap-1.5">
          <span className="text-gray-500 font-mono text-sm">.claw</span>
        </div>
      </div>

      {/* Status */}
      {showStatus && (
        <div className="mt-3 flex items-center gap-2 text-sm animate-fade-in">
          {validationError ? (
            <>
              <span className="text-red-400">✕</span>
              <span className="text-red-400">{validationError}</span>
            </>
          ) : checking ? (
            <>
              <div className="w-4 h-4 border-2 border-claw-purple/30 border-t-claw-purple rounded-full animate-spin" />
              <span className="text-gray-400">Checking availability...</span>
            </>
          ) : isAvailable === true ? (
            <>
              <span className="text-claw-green text-lg">✓</span>
              <span className="text-claw-green font-medium">
                {debouncedName}.claw is available!
              </span>
            </>
          ) : isAvailable === false ? (
            <>
              <span className="text-red-400 text-lg">✕</span>
              <span className="text-red-400">
                {debouncedName}.claw is already taken
              </span>
            </>
          ) : null}
        </div>
      )}
    </div>
  );
}
