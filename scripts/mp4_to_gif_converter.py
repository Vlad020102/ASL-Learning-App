import os
import sys
from moviepy.editor import VideoFileClip
import argparse
from pathlib import Path

def convert_mp4_to_gif(input_folder, output_folder=None, fps=10, scale=0.5, quality='medium'):
    """
    Convert all MP4 files in a folder to GIF format
    
    Args:
        input_folder (str): Path to folder containing MP4 files
        output_folder (str): Path to output folder (defaults to input_folder/gifs)
        fps (int): Frames per second for output GIF (default: 10)
        scale (float): Scale factor for resizing (default: 0.5)
        quality (str): Quality setting - 'low', 'medium', 'high' (default: 'medium')
    """
    
    # Set up paths
    input_path = Path(input_folder)
    if not input_path.exists():
        print(f"Error: Input folder '{input_folder}' does not exist")
        return
    
    if output_folder is None:
        output_path = input_path / 'gifs'
    else:
        output_path = Path(output_folder)
    
    # Create output directory if it doesn't exist
    output_path.mkdir(parents=True, exist_ok=True)
    
    # Quality settings
    quality_settings = {
        'low': {'fps': 8, 'scale': 0.3},
        'medium': {'fps': 10, 'scale': 0.5},
        'high': {'fps': 15, 'scale': 0.7}
    }
    
    if quality in quality_settings:
        fps = quality_settings[quality]['fps']
        scale = quality_settings[quality]['scale']
    
    # Find all MP4 files
    mp4_files = list(input_path.glob('*.mp4')) + list(input_path.glob('*.MP4'))
    
    if not mp4_files:
        print(f"No MP4 files found in '{input_folder}'")
        return
    
    print(f"Found {len(mp4_files)} MP4 files to convert")
    print(f"Output directory: {output_path}")
    print(f"Settings: FPS={fps}, Scale={scale}")
    print("-" * 50)
    
    successful_conversions = 0
    failed_conversions = 0
    
    for mp4_file in mp4_files:
        try:
            print(f"Converting: {mp4_file.name}... ", end="")
            
            # Generate output filename
            gif_filename = mp4_file.stem + '.gif'
            output_file = output_path / gif_filename
            
            # Skip if GIF already exists
            if output_file.exists():
                print("SKIPPED (already exists)")
                continue
            
            # Load video clip
            with VideoFileClip(str(mp4_file)) as clip:
                # Resize if scale is not 1.0
                if scale != 1.0:
                    new_width = int(clip.w * scale)
                    new_height = int(clip.h * scale)
                    clip = clip.resize((new_width, new_height))
                
                # Convert to GIF
                clip.write_gif(
                    str(output_file),
                    fps=fps,
                    opt='OptimizePlus',  # Optimize for file size
                    fuzz=1  # Reduce color palette for smaller file size
                )
            
            print("SUCCESS")
            successful_conversions += 1
            
        except Exception as e:
            print(f"FAILED - {str(e)}")
            failed_conversions += 1
    
    print("-" * 50)
    print(f"Conversion complete!")
    print(f"Successful: {successful_conversions}")
    print(f"Failed: {failed_conversions}")
    print(f"Output location: {output_path}")

def main():
    parser = argparse.ArgumentParser(description='Convert MP4 files to GIF format')
    parser.add_argument('input_folder', help='Path to folder containing MP4 files')
    parser.add_argument('-o', '--output', help='Output folder path (default: input_folder/gifs)')
    parser.add_argument('--fps', type=int, default=10, help='Frames per second for GIF (default: 10)')
    parser.add_argument('--scale', type=float, default=0.5, help='Scale factor for resizing (default: 0.5)')
    parser.add_argument('--quality', choices=['low', 'medium', 'high'], default='medium',
                       help='Quality preset (default: medium)')
    parser.add_argument('--list-only', action='store_true', help='Only list MP4 files, don\'t convert')
    
    args = parser.parse_args()
    
    if args.list_only:
        # Just list the MP4 files
        input_path = Path(args.input_folder)
        if not input_path.exists():
            print(f"Error: Input folder '{args.input_folder}' does not exist")
            return
        
        mp4_files = list(input_path.glob('*.mp4')) + list(input_path.glob('*.MP4'))
        if mp4_files:
            print(f"Found {len(mp4_files)} MP4 files:")
            for mp4_file in mp4_files:
                print(f"  - {mp4_file.name}")
        else:
            print("No MP4 files found")
        return
    
    # Perform conversion
    convert_mp4_to_gif(
        input_folder=args.input_folder,
        output_folder=args.output,
        fps=args.fps,
        scale=args.scale,
        quality=args.quality
    )

if __name__ == "__main__":
    main()
