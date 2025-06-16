import type { Meta, StoryObj } from 'storybook/internal/types';
import { Products  } from './products';
import { expect } from 'storybook/test';

const meta: Meta<typeof Products> = {
  component: Products,
  title: 'Products', 
};
export default meta;
type Story = StoryObj<typeof Products>;

export const Primary = {
  args: {
  },
};

export const Heading: Story = {
  args: {
  },
  play: async ({ canvas }) => {
    await expect(canvas.getByText(/Welcome to Products!/gi)).toBeTruthy();
  },
};

