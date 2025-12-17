---
name: brand-guidelines
description: Applies TePS'EG official brand colors and typography to any sort of artifact that may benefit from having TePS'EG's look-and-feel. Use it when brand colors or style guidelines, visual formatting, or company design standards apply.
---

# TePS'EG Brand Styling

## Overview

To access TePS'EG's official brand identity and style resources, use this skill.

**Keywords**: branding, corporate identity, visual identity, post-processing, styling, brand colors, typography, TePS'EG brand, visual formatting, visual design

## Brand Guidelines

### Colors

**Main Colors:**

- Dark Navy: `#1E3A5F` - Primary text and dark backgrounds
- White: `#FFFFFF` - Light backgrounds and text on dark
- Light Gray: `#F5F5F5` - Subtle backgrounds

**Accent Colors:**

- Cyan/Turquoise: `#4ECDC4` - Primary accent (energy, innovation)
- Blue: `#4A7FC4` - Secondary accent (trust, stability)
- Dark Navy: `#1E3A5F` - Tertiary accent (professionalism)

**Text Colors:**

- Primary Text: `#1A1A1A` - Main body text
- Secondary Text: `#4A4A4A` - Subtle text

### Typography

- **Headings**: Pretendard Bold (with Arial fallback)
- **Body Text**: Pretendard Regular (with Noto Sans KR fallback)
- **Note**: Fonts should be pre-installed in your environment for best results

## Features

### Smart Font Application

- Applies Pretendard Bold to headings (24pt and larger)
- Applies Pretendard Regular to body text
- Automatically falls back to Arial/Noto Sans KR if custom fonts unavailable
- Preserves readability across all systems

### Text Styling

- Headings (24pt+): Pretendard Bold
- Body text: Pretendard Regular
- Smart color selection based on background
- Preserves text hierarchy and formatting

### Shape and Accent Colors

- Non-text shapes use accent colors
- Cycles through Cyan, Blue, and Dark Navy accents
- Maintains visual interest while staying on-brand

## Technical Details

### Font Management

- Uses system-installed Pretendard fonts when available
- Provides automatic fallback to Arial (headings) and Noto Sans KR (body)
- No font installation required - works with existing system fonts
- For best results, pre-install Pretendard fonts in your environment

### Color Application

- Uses RGB color values for precise brand matching
- Applied via python-pptx's RGBColor class
- Maintains color fidelity across different systems

## Logo Usage

The TePS'EG logo consists of three interlocking hexagonal shapes representing:
- **Cyan**: Innovation and energy
- **Blue**: Trust and stability
- **Dark Navy**: Professionalism and expertise

Always maintain clear space around the logo and use approved color variations only.
