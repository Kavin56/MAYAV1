import type { JSX } from "solid-js";

type Props = {
  size?: number;
  class?: string;
};

export default function OpenWorkLogo(props: Props): JSX.Element {
  const size = props.size ?? 72;
  
  return (
    <img
      src="/maya-v1-logo.png"
      alt="MAYA"
      width={size}
      height={size}
      class={`inline-block drop-shadow-md ${props.class ?? ""}`}
    />
  );
}
