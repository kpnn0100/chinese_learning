#!/usr/bin/env python3
"""
Script to update CSV files with accurate pinyin using pypinyin library
"""

import csv
from pypinyin import pinyin, Style
from pathlib import Path


def get_accurate_pinyin(chinese_text):
    """Convert Chinese text to pinyin with tone numbers"""
    # Get pinyin with tone marks
    result = pinyin(chinese_text, style=Style.TONE)
    # Join the pinyin syllables with space
    return ' '.join([p[0] for p in result])


def update_csv_pinyin(csv_path):
    """Update the pinyin column in a CSV file"""
    rows = []
    
    # Read existing CSV
    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames
        
        for row in reader:
            chinese = row.get('Chinese', '')
            old_pinyin = row.get('Pinyin', '')
            new_pinyin = get_accurate_pinyin(chinese)
            
            # Show changes
            if old_pinyin.lower().replace(' ', '') != new_pinyin.lower().replace(' ', ''):
                print(f"{chinese}: '{old_pinyin}' -> '{new_pinyin}'")
            
            row['Pinyin'] = new_pinyin
            rows.append(row)
    
    # Write updated CSV
    with open(csv_path, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    
    print(f"\nUpdated {len(rows)} entries in {csv_path}")


def main():
    resource_dir = Path(__file__).parent / "resource"
    
    # Update HSK1
    hsk1_path = resource_dir / "hsk1.csv"
    if hsk1_path.exists():
        print("=== Updating HSK1 ===")
        update_csv_pinyin(hsk1_path)
    
    # Update HSK2 if exists
    hsk2_path = resource_dir / "hsk2.csv"
    if hsk2_path.exists():
        print("\n=== Updating HSK2 ===")
        update_csv_pinyin(hsk2_path)


if __name__ == "__main__":
    main()
