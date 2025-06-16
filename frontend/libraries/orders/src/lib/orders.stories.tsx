import type { Meta, StoryObj } from 'storybook/internal/types';
import { Orders  } from './orders';
import { expect } from 'storybook/test';

const meta: Meta<typeof Orders> = {
  component: Orders,
  title: 'Orders', 
};
export default meta;
type Story = StoryObj<typeof Orders>;

export const Primary = {
  args: {
  },
};

export const Heading: Story = {
  args: {
  },
  play: async ({ canvas }) => {
    await expect(canvas.getByText(/Welcome to Orders!/gi)).toBeTruthy();
  },
};

