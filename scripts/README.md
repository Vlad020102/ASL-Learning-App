# MP4 to GIF Converter

This script converts MP4 video files to optimized GIF format, useful for creating lightweight animated assets for the ASL Learning App.

## Installation

1. Install required dependencies:
```bash
pip install -r requirements.txt
```

## Usage

### Basic Usage
Convert all MP4 files in a folder:
```bash
python mp4_to_gif_converter.py /path/to/your/mp4/folder
```

### Advanced Usage
```bash
# Specify output folder
python mp4_to_gif_converter.py /path/to/mp4s -o /path/to/output

# Custom settings
python mp4_to_gif_converter.py /path/to/mp4s --fps 15 --scale 0.7

# Use quality presets
python mp4_to_gif_converter.py /path/to/mp4s --quality high

# List MP4 files without converting
python mp4_to_gif_converter.py /path/to/mp4s --list-only
```

## Parameters

- `input_folder`: Path to folder containing MP4 files
- `-o, --output`: Output folder (default: creates 'gifs' subfolder in input folder)
- `--fps`: Frames per second for output GIF (default: 10)
- `--scale`: Scale factor for resizing (default: 0.5)
- `--quality`: Quality preset - 'low', 'medium', 'high' (default: 'medium')
- `--list-only`: Only list MP4 files without converting

## Quality Presets

- **Low**: 8 FPS, 30% scale - smallest file size
- **Medium**: 10 FPS, 50% scale - balanced quality/size
- **High**: 15 FPS, 70% scale - best quality

## Examples

Convert for web use (small file size):
```bash
python mp4_to_gif_converter.py ./videos --quality low
```

Convert for high-quality display:
```bash
python mp4_to_gif_converter.py ./videos --fps 20 --scale 1.0
```

## Notes

- The script automatically skips files that have already been converted
- Original MP4 files are not modified or deleted
- GIF files are optimized for web usage with reduced color palettes
- Processing time depends on video length and quality settings
