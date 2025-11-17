#!/usr/bin/env python3
"""
Chinese Flashcard Learning System
Learn Chinese vocabulary using HSK levels with flashcard method
"""

import csv
import random
import json
import os
from pathlib import Path


# ANSI color codes
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    CYAN = '\033[96m'
    YELLOW = '\033[93m'
    BOLD = '\033[1m'
    RESET = '\033[0m'


class ChineseFlashcard:
    def __init__(self):
        self.resource_dir = Path(__file__).parent / "resource"
        self.config_file = Path(__file__).parent / "config.json"
        self.progress_file = Path(__file__).parent / "progress.json"
        self.revision_file = Path(__file__).parent / "revision.txt"
        
        # Default configuration
        self.config = {
            "hsk_level": 1,
            "words_per_patch": 10
        }
        
        # Progress tracking
        self.progress = {
            "current_index": 0,
            "shuffled_indices": []
        }
        
        self.words = []
        self.load_config()
        self.load_progress()
        self.load_words()
    
    def load_config(self):
        """Load configuration from file"""
        if self.config_file.exists():
            with open(self.config_file, 'r', encoding='utf-8') as f:
                self.config.update(json.load(f))
    
    def save_config(self):
        """Save configuration to file"""
        with open(self.config_file, 'w', encoding='utf-8') as f:
            json.dump(self.config, f, indent=2)
    
    def load_progress(self):
        """Load progress from file"""
        if self.progress_file.exists():
            with open(self.progress_file, 'r', encoding='utf-8') as f:
                self.progress.update(json.load(f))
    
    def save_progress(self):
        """Save progress to file"""
        with open(self.progress_file, 'w', encoding='utf-8') as f:
            json.dump(self.progress, f, indent=2)
    
    def load_words(self):
        """Load words from HSK CSV file"""
        hsk_file = self.resource_dir / f"hsk{self.config['hsk_level']}.csv"
        
        if not hsk_file.exists():
            print(f"Error: {hsk_file} not found!")
            return
        
        self.words = []
        with open(hsk_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                # Handle different column name formats (case-insensitive)
                row_lower = {k.lower(): v for k, v in row.items()}
                
                self.words.append({
                    'chinese': row.get('Chinese') or row.get('chinese', ''),
                    'pinyin': row.get('Pinyin') or row.get('pinyin', ''),
                    'meaning': row.get('Meaning_English') or row.get('meaning', ''),
                    'han_viet': row.get('Han_Viet') or row.get('han_viet', ''),
                    'nghia_tieng_viet': row.get('Nghia_Tieng_Viet') or row.get('nghia_tieng_viet', ''),
                    'cach_dung': row.get('Cach_dung_trong_cau') or row.get('cach_dung_trong_cau', '')
                })
        
        # Initialize shuffled indices if not exists or if word count changed
        if not self.progress['shuffled_indices'] or len(self.progress['shuffled_indices']) != len(self.words):
            self.progress['shuffled_indices'] = list(range(len(self.words)))
            random.shuffle(self.progress['shuffled_indices'])
            self.progress['current_index'] = 0
            self.save_progress()
    
    def normalize_pinyin(self, pinyin):
        """Normalize pinyin for comparison (remove spaces, lowercase)"""
        return pinyin.lower().replace(' ', '').replace(',', '')
    
    def convert_tone_marks(self, pinyin):
        """Convert tone marks to numbers for display"""
        tone_map = {
            'ā': 'a1', 'á': 'a2', 'ǎ': 'a3', 'à': 'a4',
            'ē': 'e1', 'é': 'e2', 'ě': 'e3', 'è': 'e4',
            'ī': 'i1', 'í': 'i2', 'ǐ': 'i3', 'ì': 'i4',
            'ō': 'o1', 'ó': 'o2', 'ǒ': 'o3', 'ò': 'o4',
            'ū': 'u1', 'ú': 'u2', 'ǔ': 'u3', 'ù': 'u4',
            'ǖ': 'ü1', 'ǘ': 'ü2', 'ǚ': 'ü3', 'ǜ': 'ü4',
            'ü': 'v', 'ń': 'n2', 'ň': 'n3', 'ǹ': 'n4'
        }
        
        result = pinyin
        for mark, num in tone_map.items():
            result = result.replace(mark, num)
        return result
    
    def check_pinyin_answer(self, user_input, correct_pinyin):
        """Check if user's pinyin input is correct"""
        # Convert correct pinyin tone marks to numbers, then normalize
        correct_with_numbers = self.convert_tone_marks(correct_pinyin)
        
        # Normalize both inputs
        user_normalized = self.normalize_pinyin(user_input)
        correct_normalized = self.normalize_pinyin(correct_with_numbers)
        
        return user_normalized == correct_normalized
    
    def get_current_patch(self):
        """Get current patch of words based on current index"""
        words_per_patch = self.config['words_per_patch']
        current_idx = self.progress['current_index']
        shuffled_indices = self.progress['shuffled_indices']
        
        start = current_idx * words_per_patch
        end = min(start + words_per_patch, len(shuffled_indices))
        
        if start >= len(shuffled_indices):
            return []
        
        patch_indices = shuffled_indices[start:end]
        return [self.words[i] for i in patch_indices]
    
    def get_previous_patch(self):
        """Get previous patch of words"""
        if self.progress['current_index'] == 0:
            return []
        
        words_per_patch = self.config['words_per_patch']
        prev_idx = self.progress['current_index'] - 1
        shuffled_indices = self.progress['shuffled_indices']
        
        start = prev_idx * words_per_patch
        end = min(start + words_per_patch, len(shuffled_indices))
        
        patch_indices = shuffled_indices[start:end]
        return [self.words[i] for i in patch_indices]
    
    def save_word_to_revision(self, word):
        """Save a word to revision.txt file"""
        # Read existing revision words to avoid duplicates
        existing_words = set()
        if self.revision_file.exists():
            with open(self.revision_file, 'r', encoding='utf-8') as f:
                for line in f:
                    parts = line.strip().split('|')
                    if len(parts) >= 2:
                        existing_words.add(parts[0])  # Chinese character
        
        # Only add if not already in revision
        if word['chinese'] not in existing_words:
            with open(self.revision_file, 'a', encoding='utf-8') as f:
                # Format: Chinese|Pinyin|Meaning|Han_Viet|Nghia_Tieng_Viet|Cach_dung
                f.write(f"{word['chinese']}|{word['pinyin']}|{word['meaning']}|{word.get('han_viet', '')}|{word.get('nghia_tieng_viet', '')}|{word.get('cach_dung', '')}\n")
    
    def load_revision_words(self):
        """Load words from revision.txt file"""
        if not self.revision_file.exists():
            return []
        
        revision_words = []
        with open(self.revision_file, 'r', encoding='utf-8') as f:
            for line in f:
                parts = line.strip().split('|')
                if len(parts) >= 3:
                    revision_words.append({
                        'chinese': parts[0],
                        'pinyin': parts[1],
                        'meaning': parts[2],
                        'han_viet': parts[3] if len(parts) > 3 else '',
                        'nghia_tieng_viet': parts[4] if len(parts) > 4 else '',
                        'cach_dung': parts[5] if len(parts) > 5 else ''
                    })
        
        return revision_words
    
    def remove_word_from_revision(self, word):
        """Remove a word from revision.txt file"""
        if not self.revision_file.exists():
            return
        
        # Read all words except the one to remove
        remaining_words = []
        with open(self.revision_file, 'r', encoding='utf-8') as f:
            for line in f:
                parts = line.strip().split('|')
                if len(parts) >= 1 and parts[0] != word['chinese']:
                    remaining_words.append(line)
        
        # Write back the remaining words
        with open(self.revision_file, 'w', encoding='utf-8') as f:
            f.writelines(remaining_words)
    
    def flashcard_session(self, words):
        """Run a flashcard learning session with endless shuffle"""
        if not words:
            print("No words in this patch!")
            return
        
        print(f"\n{'='*60}")
        print(f"Flashcard Session - {len(words)} words (endless mode)")
        print(f"{'='*60}")
        print("Press Ctrl+C to exit the session\n")
        
        word_count = 0
        try:
            while True:
                # Shuffle words for each round
                shuffled_words = words.copy()
                random.shuffle(shuffled_words)
                
                for word in shuffled_words:
                    word_count += 1
                    # Randomly choose question type
                    question_type = random.choice(['chinese_to_pinyin', 'meaning_to_pinyin'])
                    
                    print(f"\nWord #{word_count}")
                    print("-" * 40)
                    
                    if question_type == 'chinese_to_pinyin':
                        print(f"Chinese: {Colors.BOLD}{Colors.CYAN}{word['chinese']}{Colors.RESET}")
                        user_input = input("Type the pinyin (use 1234 for tones): ").strip()
                        
                        correct = self.check_pinyin_answer(user_input, word['pinyin'])
                        
                        if correct:
                            print(f"{Colors.GREEN}✓ Correct!{Colors.RESET}")
                            print(f"Meaning: {word['meaning']}")
                            if word.get('han_viet'):
                                print(f"Hán Việt: {word['han_viet']}")
                            if word.get('nghia_tieng_viet'):
                                print(f"Nghĩa Tiếng Việt: {word['nghia_tieng_viet']}")
                            if word.get('cach_dung'):
                                print(f"Cách dùng: {word['cach_dung']}")
                        else:
                            print(f"{Colors.RED}✗ Incorrect. Correct answer: {self.convert_tone_marks(word['pinyin'])}{Colors.RESET}")
                            print(f"Meaning: {word['meaning']}")
                            if word.get('han_viet'):
                                print(f"Hán Việt: {word['han_viet']}")
                            if word.get('nghia_tieng_viet'):
                                print(f"Nghĩa Tiếng Việt: {word['nghia_tieng_viet']}")
                            if word.get('cach_dung'):
                                print(f"Cách dùng: {word['cach_dung']}")
                    
                    else:  # meaning_to_pinyin
                        print(f"Meaning: {word['meaning']}")
                        user_input = input("Type the pinyin (use 1234 for tones): ").strip()
                        
                        correct = self.check_pinyin_answer(user_input, word['pinyin'])
                        
                        if correct:
                            print(f"{Colors.GREEN}✓ Correct!{Colors.RESET}")
                            print(f"Chinese: {Colors.BOLD}{Colors.CYAN}{word['chinese']}{Colors.RESET}")
                            if word.get('han_viet'):
                                print(f"Hán Việt: {word['han_viet']}")
                            if word.get('nghia_tieng_viet'):
                                print(f"Nghĩa Tiếng Việt: {word['nghia_tieng_viet']}")
                            if word.get('cach_dung'):
                                print(f"Cách dùng: {word['cach_dung']}")
                        else:
                            print(f"{Colors.RED}✗ Incorrect. Correct answer: {self.convert_tone_marks(word['pinyin'])}{Colors.RESET}")
                            print(f"Chinese: {Colors.BOLD}{Colors.CYAN}{word['chinese']}{Colors.RESET}")
                            if word.get('han_viet'):
                                print(f"Hán Việt: {word['han_viet']}")
                            if word.get('nghia_tieng_viet'):
                                print(f"Nghĩa Tiếng Việt: {word['nghia_tieng_viet']}")
                            if word.get('cach_dung'):
                                print(f"Cách dùng: {word['cach_dung']}")
                    
                    input("\nPress Enter to continue...")
        
        except KeyboardInterrupt:
            print(f"\n\n{'='*60}")
            print(f"Session ended! You practiced {word_count} word(s).")
            print(f"{'='*60}\n")
    
    def test_session(self, num_previous_patches):
        """Test previous patches of words"""
        if self.progress['current_index'] == 0:
            print("No previous patches to test!")
            return
        
        words_per_patch = self.config['words_per_patch']
        current_idx = self.progress['current_index']
        
        # Calculate how many patches we can actually test
        max_patches = min(num_previous_patches, current_idx)
        
        # Get words from previous patches
        shuffled_indices = self.progress['shuffled_indices']
        start = (current_idx - max_patches) * words_per_patch
        end = current_idx * words_per_patch
        
        test_indices = shuffled_indices[start:end]
        test_words = [self.words[i] for i in test_indices]
        
        # Shuffle test words
        random.shuffle(test_words)
        
        print(f"\n{'='*60}")
        print(f"Test Session - {len(test_words)} words from {max_patches} previous patch(es)")
        print(f"{'='*60}\n")
        
        correct_count = 0
        
        for i, word in enumerate(test_words, 1):
            print(f"\nQuestion {i}/{len(test_words)}")
            print("-" * 40)
            
            # Always show Chinese character in test
            print(f"Chinese: {Colors.BOLD}{Colors.CYAN}{word['chinese']}{Colors.RESET}")
            user_input = input("Type the pinyin (use 1234 for tones): ").strip()
            
            correct = self.check_pinyin_answer(user_input, word['pinyin'])
            
            if correct:
                print(f"{Colors.GREEN}✓ Correct!{Colors.RESET}")
                print(f"Meaning: {word['meaning']}")
                if word.get('han_viet'):
                    print(f"Hán Việt: {word['han_viet']}")
                if word.get('nghia_tieng_viet'):
                    print(f"Nghĩa Tiếng Việt: {word['nghia_tieng_viet']}")
                if word.get('cach_dung'):
                    print(f"Cách dùng: {word['cach_dung']}")
                correct_count += 1
            else:
                print(f"{Colors.RED}✗ Incorrect. Correct answer: {self.convert_tone_marks(word['pinyin'])}{Colors.RESET}")
                print(f"Meaning: {word['meaning']}")
                if word.get('han_viet'):
                    print(f"Hán Việt: {word['han_viet']}")
                if word.get('nghia_tieng_viet'):
                    print(f"Nghĩa Tiếng Việt: {word['nghia_tieng_viet']}")
                if word.get('cach_dung'):
                    print(f"Cách dùng: {word['cach_dung']}")
                # Save wrong word to revision
                self.save_word_to_revision(word)
        
        # Calculate score
        score = (correct_count / len(test_words)) * 100
        
        print(f"\n{'='*60}")
        print(f"Test Complete!")
        print(f"Score: {correct_count}/{len(test_words)} ({score:.1f}%)")
        print(f"{'='*60}\n")
    
    def revision_test_session(self):
        """Test revision words and remove correct ones"""
        revision_words = self.load_revision_words()
        
        if not revision_words:
            print("\nNo words in revision! Your revision list is empty.")
            return
        
        # Shuffle revision words
        random.shuffle(revision_words)
        
        print(f"\n{'='*60}")
        print(f"Revision Test Session - {len(revision_words)} words")
        print(f"{'='*60}\n")
        print("Correct answers will be removed from revision list.\n")
        
        correct_count = 0
        words_to_remove = []
        
        for i, word in enumerate(revision_words, 1):
            print(f"\nQuestion {i}/{len(revision_words)}")
            print("-" * 40)
            
            # Always show Chinese character in test
            print(f"Chinese: {Colors.BOLD}{Colors.CYAN}{word['chinese']}{Colors.RESET}")
            user_input = input("Type the pinyin (use 1234 for tones): ").strip()
            
            correct = self.check_pinyin_answer(user_input, word['pinyin'])
            
            if correct:
                print(f"{Colors.GREEN}✓ Correct! This word will be removed from revision.{Colors.RESET}")
                print(f"Meaning: {word['meaning']}")
                if word.get('han_viet'):
                    print(f"Hán Việt: {word['han_viet']}")
                if word.get('nghia_tieng_viet'):
                    print(f"Nghĩa Tiếng Việt: {word['nghia_tieng_viet']}")
                if word.get('cach_dung'):
                    print(f"Cách dùng: {word['cach_dung']}")
                correct_count += 1
                words_to_remove.append(word)
            else:
                print(f"{Colors.RED}✗ Incorrect. Correct answer: {self.convert_tone_marks(word['pinyin'])}{Colors.RESET}")
                print(f"This word will remain in your revision list.")
                print(f"Meaning: {word['meaning']}")
                if word.get('han_viet'):
                    print(f"Hán Việt: {word['han_viet']}")
                if word.get('nghia_tieng_viet'):
                    print(f"Nghĩa Tiếng Việt: {word['nghia_tieng_viet']}")
                if word.get('cach_dung'):
                    print(f"Cách dùng: {word['cach_dung']}")
        
        # Remove correct words from revision
        for word in words_to_remove:
            self.remove_word_from_revision(word)
        
        # Calculate score
        score = (correct_count / len(revision_words)) * 100
        remaining = len(revision_words) - correct_count
        
        print(f"\n{'='*60}")
        print(f"Revision Test Complete!")
        print(f"Score: {correct_count}/{len(revision_words)} ({score:.1f}%)")
        print(f"Words removed from revision: {correct_count}")
        print(f"Words remaining in revision: {remaining}")
        print(f"{'='*60}\n")
    
    def show_config_menu(self):
        """Show configuration menu"""
        while True:
            print(f"\n{'='*60}")
            print("Configuration")
            print(f"{'='*60}")
            print(f"1. HSK Level: {self.config['hsk_level']}")
            print(f"2. Words per patch: {self.config['words_per_patch']}")
            print("3. Reset progress (reshuffle and start from beginning)")
            print("4. Back to main menu")
            print(f"{'='*60}")
            
            choice = input("\nSelect option (1-4): ").strip()
            
            if choice == '1':
                try:
                    level = int(input("Enter HSK level (1-6): "))
                    if 1 <= level <= 6:
                        old_level = self.config['hsk_level']
                        self.config['hsk_level'] = level
                        self.save_config()
                        self.load_words()
                        print(f"HSK level changed from {old_level} to {level}")
                        print("Progress has been reset for the new level.")
                    else:
                        print("Invalid level. Please enter 1-6.")
                except ValueError:
                    print("Invalid input. Please enter a number.")
            
            elif choice == '2':
                try:
                    words = int(input("Enter words per patch: "))
                    if words > 0:
                        self.config['words_per_patch'] = words
                        self.save_config()
                        print(f"Words per patch set to {words}")
                    else:
                        print("Please enter a positive number.")
                except ValueError:
                    print("Invalid input. Please enter a number.")
            
            elif choice == '3':
                confirm = input("Are you sure you want to reset progress? (yes/no): ").strip().lower()
                if confirm == 'yes':
                    self.progress['shuffled_indices'] = list(range(len(self.words)))
                    random.shuffle(self.progress['shuffled_indices'])
                    self.progress['current_index'] = 0
                    self.save_progress()
                    print("Progress has been reset!")
            
            elif choice == '4':
                break
            else:
                print("Invalid choice. Please select 1-4.")
    
    def show_main_menu(self):
        """Show main menu"""
        while True:
            current_patch = self.progress['current_index'] + 1
            total_patches = (len(self.words) + self.config['words_per_patch'] - 1) // self.config['words_per_patch']
            revision_count = len(self.load_revision_words())
            
            print(f"\n{'='*60}")
            print("Chinese Flashcard Learning System")
            print(f"{'='*60}")
            print(f"HSK Level: {self.config['hsk_level']} | Words per patch: {self.config['words_per_patch']}")
            print(f"Current patch: {current_patch}/{total_patches}")
            print(f"Total words: {len(self.words)} | Revision words: {revision_count}")
            print(f"{'='*60}")
            print("1. Start - Learn current patch")
            print("2. Next - Move to next patch")
            print("3. Previous - Move to previous patch")
            print("4. Test - Test previous patches")
            print("5. Start with Revision - Practice revision words")
            print("6. Test Revision - Test and remove mastered words")
            print("7. Config - Configuration settings")
            print("8. Exit")
            print(f"{'='*60}")
            
            choice = input("\nSelect option (1-8): ").strip()
            
            if choice == '1':
                words = self.get_current_patch()
                if words:
                    self.flashcard_session(words)
                else:
                    print("No more words! You've completed all patches.")
            
            elif choice == '2':
                words_per_patch = self.config['words_per_patch']
                total_patches = (len(self.words) + words_per_patch - 1) // words_per_patch
                
                if self.progress['current_index'] < total_patches - 1:
                    self.progress['current_index'] += 1
                    self.save_progress()
                    print(f"Moved to patch {self.progress['current_index'] + 1}")
                else:
                    print("You're already at the last patch!")
            
            elif choice == '3':
                if self.progress['current_index'] > 0:
                    self.progress['current_index'] -= 1
                    self.save_progress()
                    print(f"Moved to patch {self.progress['current_index'] + 1}")
                else:
                    print("You're already at the first patch!")
            
            elif choice == '4':
                if self.progress['current_index'] == 0:
                    print("No previous patches to test! Learn the first patch first.")
                else:
                    try:
                        num_patches = int(input(f"How many previous patches to test? (1-{self.progress['current_index']}): "))
                        if 1 <= num_patches <= self.progress['current_index']:
                            self.test_session(num_patches)
                        else:
                            print(f"Please enter a number between 1 and {self.progress['current_index']}.")
                    except ValueError:
                        print("Invalid input. Please enter a number.")
            
            elif choice == '5':
                revision_words = self.load_revision_words()
                if revision_words:
                    self.flashcard_session(revision_words)
                else:
                    print("\nNo words in revision! Your revision list is empty.")
            
            elif choice == '6':
                self.revision_test_session()
            
            elif choice == '7':
                self.show_config_menu()
            
            elif choice == '8':
                print("\nGoodbye! Keep learning! 加油!")
                break
            
            else:
                print("Invalid choice. Please select 1-8.")
    
    def run(self):
        """Run the flashcard application"""
        print("\n" + "="*60)
        print("Welcome to Chinese Flashcard Learning System!")
        print("="*60)
        print("\nTips:")
        print("- Use numbers 1, 2, 3, 4 for tones in pinyin")
        print("  Example: ni3hao3 for 你好")
        print("- You can omit spaces in pinyin input")
        print("="*60)
        
        self.show_main_menu()


def main():
    app = ChineseFlashcard()
    app.run()


if __name__ == "__main__":
    main()
