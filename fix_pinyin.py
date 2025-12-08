#!/usr/bin/env python3
"""
Script to fix specific pinyin that have multiple pronunciations
"""

import csv
from pathlib import Path

# Words with specific pronunciations based on meaning
# Format: {Chinese: correct_pinyin}
FIXES = {
    # HSK1
    '谁': 'shéi',  # who (shéi is more common in speech, shuí is formal)
    
    # HSK2
    '长': 'cháng',  # long (not zhǎng which means "to grow")
    '还': 'hái',    # still/also (not huán which means "to return")
    '得': 'de',     # particle (context dependent, but 'de' for complement)
}


def fix_csv_pinyin(csv_path, fixes):
    """Fix specific pinyin entries in a CSV file"""
    rows = []
    changes = []
    
    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames
        
        for row in reader:
            chinese = row.get('Chinese', '')
            if chinese in fixes:
                old_pinyin = row.get('Pinyin', '')
                new_pinyin = fixes[chinese]
                if old_pinyin != new_pinyin:
                    changes.append(f"{chinese}: '{old_pinyin}' -> '{new_pinyin}'")
                    row['Pinyin'] = new_pinyin
            rows.append(row)
    
    if changes:
        with open(csv_path, 'w', encoding='utf-8', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(rows)
        
        print(f"Fixed in {csv_path.name}:")
        for change in changes:
            print(f"  {change}")
    else:
        print(f"No fixes needed in {csv_path.name}")


def main():
    resource_dir = Path(__file__).parent / "resource"
    
    for hsk_file in ['hsk1.csv', 'hsk2.csv']:
        csv_path = resource_dir / hsk_file
        if csv_path.exists():
            fix_csv_pinyin(csv_path, FIXES)


if __name__ == "__main__":
    main()
