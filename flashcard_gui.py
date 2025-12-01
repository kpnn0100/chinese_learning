#!/usr/bin/env python3
"""
Chinese Flashcard Learning System - GUI Version
Learn Chinese vocabulary using HSK levels with a beautiful tkinter interface
"""

import tkinter as tk
from tkinter import ttk, messagebox, font
import csv
import random
import json
import os
from pathlib import Path


class ChineseFlashcardGUI:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Chinese Flashcard Learning System")
        self.root.geometry("800x600")
        self.root.configure(bg="#F5F5F5")
        
        # Paths
        self.resource_dir = Path(__file__).parent / "resource"
        self.config_file = Path(__file__).parent / "config.json"
        self.progress_file = Path(__file__).parent / "progress.json"
        self.revision_file = Path(__file__).parent / "revision.txt"
        
        # Configuration
        self.config = {"hsk_level": 1, "words_per_patch": 10}
        self.progress = {"current_index": 0, "shuffled_indices": []}
        self.words = []
        
        # Load data
        self.load_config()
        self.load_progress()
        self.load_words()
        
        # Create main menu
        self.create_main_menu()
        
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
            messagebox.showerror("Error", f"File {hsk_file} not found!")
            return
        
        self.words = []
        with open(hsk_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                self.words.append({
                    'chinese': row.get('Chinese', ''),
                    'pinyin': row.get('Pinyin', ''),
                    'meaning': row.get('Meaning_English', ''),
                    'han_viet': row.get('Han_Viet', ''),
                    'nghia_tieng_viet': row.get('Nghia_Tieng_Viet', ''),
                    'cach_dung': row.get('Cach_dung_trong_cau', '')
                })
        
        # Initialize shuffled indices
        if not self.progress['shuffled_indices'] or len(self.progress['shuffled_indices']) != len(self.words):
            self.progress['shuffled_indices'] = list(range(len(self.words)))
            random.shuffle(self.progress['shuffled_indices'])
            self.progress['current_index'] = 0
            self.save_progress()
    
    def create_main_menu(self):
        """Create the main menu interface"""
        # Clear window
        for widget in self.root.winfo_children():
            widget.destroy()
        
        # Title
        title_frame = tk.Frame(self.root, bg="#F5F5F5")
        title_frame.pack(pady=20)
        
        title_label = tk.Label(title_frame, text="Chinese Flashcard", 
                              font=("Arial", 28, "bold"), fg="#2196F3", bg="#F5F5F5")
        title_label.pack()
        
        subtitle_label = tk.Label(title_frame, text="学习中文", 
                                 font=("Arial", 20), fg="#666666", bg="#F5F5F5")
        subtitle_label.pack()
        
        # Info card
        info_frame = tk.Frame(self.root, bg="white", relief=tk.RAISED, bd=2)
        info_frame.pack(pady=10, padx=40, fill=tk.X)
        
        current_patch = self.progress['current_index'] + 1
        total_patches = (len(self.words) + self.config['words_per_patch'] - 1) // self.config['words_per_patch']
        revision_count = len(self.load_revision_words())
        
        info_text = f"HSK Level: {self.config['hsk_level']} | Words per patch: {self.config['words_per_patch']}\n"
        info_text += f"Current Patch: {current_patch}/{total_patches}\n"
        info_text += f"Total Words: {len(self.words)} | Revision: {revision_count}"
        
        info_label = tk.Label(info_frame, text=info_text, font=("Arial", 12), 
                             bg="white", fg="#333333", justify=tk.LEFT, pady=10, padx=10)
        info_label.pack()
        
        # Button container
        button_frame = tk.Frame(self.root, bg="#F5F5F5")
        button_frame.pack(pady=20, padx=40, fill=tk.BOTH, expand=True)
        
        # Learning section
        learning_label = tk.Label(button_frame, text="Learning", 
                                 font=("Arial", 14, "bold"), fg="#666666", bg="#F5F5F5")
        learning_label.pack(anchor=tk.W, pady=(0, 10))
        
        btn_start = tk.Button(button_frame, text="📚 Start - Learn Current Patch", 
                             font=("Arial", 14), bg="#4CAF50", fg="white", 
                             height=2, command=self.start_learning)
        btn_start.pack(fill=tk.X, pady=5)
        
        btn_revision = tk.Button(button_frame, text="🔄 Start with Revision", 
                                font=("Arial", 14), bg="#FF9800", fg="white", 
                                height=2, command=self.start_revision)
        btn_revision.pack(fill=tk.X, pady=5)
        
        # Navigation section
        nav_label = tk.Label(button_frame, text="Navigation", 
                            font=("Arial", 14, "bold"), fg="#666666", bg="#F5F5F5")
        nav_label.pack(anchor=tk.W, pady=(20, 10))
        
        nav_buttons = tk.Frame(button_frame, bg="#F5F5F5")
        nav_buttons.pack(fill=tk.X, pady=5)
        
        btn_prev = tk.Button(nav_buttons, text="⬅️ Previous", 
                            font=("Arial", 14), bg="#2196F3", fg="white", 
                            height=2, command=self.move_previous)
        btn_prev.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5))
        
        btn_next = tk.Button(nav_buttons, text="Next ➡️", 
                            font=("Arial", 14), bg="#2196F3", fg="white", 
                            height=2, command=self.move_next)
        btn_next.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(5, 0))
        
        # Testing section
        test_label = tk.Label(button_frame, text="Testing", 
                             font=("Arial", 14, "bold"), fg="#666666", bg="#F5F5F5")
        test_label.pack(anchor=tk.W, pady=(20, 10))
        
        btn_test = tk.Button(button_frame, text="✏️ Test Previous Patches", 
                            font=("Arial", 14), bg="#9C27B0", fg="white", 
                            height=2, command=self.start_test)
        btn_test.pack(fill=tk.X, pady=5)
        
        btn_test_revision = tk.Button(button_frame, text="✅ Test Revision", 
                                      font=("Arial", 14), bg="#E91E63", fg="white", 
                                      height=2, command=self.start_test_revision)
        btn_test_revision.pack(fill=tk.X, pady=5)
        
        # Settings section
        settings_label = tk.Label(button_frame, text="Settings", 
                                 font=("Arial", 14, "bold"), fg="#666666", bg="#F5F5F5")
        settings_label.pack(anchor=tk.W, pady=(20, 10))
        
        btn_config = tk.Button(button_frame, text="⚙️ Configuration", 
                              font=("Arial", 14), bg="#607D8B", fg="white", 
                              height=2, command=self.open_config)
        btn_config.pack(fill=tk.X, pady=5)
        
        btn_exit = tk.Button(button_frame, text="🚪 Exit", 
                            font=("Arial", 14), bg="#757575", fg="white", 
                            height=2, command=self.root.quit)
        btn_exit.pack(fill=tk.X, pady=5)
    
    def get_current_patch(self):
        """Get current patch of words"""
        words_per_patch = self.config['words_per_patch']
        current_idx = self.progress['current_index']
        shuffled_indices = self.progress['shuffled_indices']
        
        start = current_idx * words_per_patch
        end = min(start + words_per_patch, len(shuffled_indices))
        
        if start >= len(shuffled_indices):
            return []
        
        return [self.words[i] for i in shuffled_indices[start:end]]
    
    def move_next(self):
        """Move to next patch"""
        words_per_patch = self.config['words_per_patch']
        total_patches = (len(self.words) + words_per_patch - 1) // words_per_patch
        
        if self.progress['current_index'] < total_patches - 1:
            self.progress['current_index'] += 1
            self.save_progress()
            messagebox.showinfo("Success", f"Moved to patch {self.progress['current_index'] + 1}")
            self.create_main_menu()
        else:
            messagebox.showinfo("Info", "You're already at the last patch!")
    
    def move_previous(self):
        """Move to previous patch"""
        if self.progress['current_index'] > 0:
            self.progress['current_index'] -= 1
            self.save_progress()
            messagebox.showinfo("Success", f"Moved to patch {self.progress['current_index'] + 1}")
            self.create_main_menu()
        else:
            messagebox.showinfo("Info", "You're already at the first patch!")
    
    def start_learning(self):
        """Start learning current patch"""
        words = self.get_current_patch()
        if not words:
            messagebox.showinfo("Info", "No more words! You've completed all patches.")
            return
        
        FlashcardWindow(self.root, words, self, is_test=False, is_revision=False)
    
    def start_revision(self):
        """Start revision practice"""
        words = self.load_revision_words()
        if not words:
            messagebox.showinfo("Info", "No words in revision! Your revision list is empty.")
            return
        
        FlashcardWindow(self.root, words, self, is_test=False, is_revision=True)
    
    def start_test(self):
        """Start test for previous patches"""
        if self.progress['current_index'] == 0:
            messagebox.showinfo("Info", "No previous patches to test! Learn the first patch first.")
            return
        
        TestSetupDialog(self.root, self)
    
    def start_test_revision(self):
        """Start revision test"""
        words = self.load_revision_words()
        if not words:
            messagebox.showinfo("Info", "No words in revision! Your revision list is empty.")
            return
        
        FlashcardWindow(self.root, words, self, is_test=True, is_revision=True)
    
    def open_config(self):
        """Open configuration window"""
        ConfigWindow(self.root, self)
    
    def load_revision_words(self):
        """Load words from revision.txt"""
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
    
    def save_word_to_revision(self, word):
        """Save a word to revision.txt"""
        existing_words = set()
        if self.revision_file.exists():
            with open(self.revision_file, 'r', encoding='utf-8') as f:
                for line in f:
                    parts = line.strip().split('|')
                    if len(parts) >= 2:
                        existing_words.add(parts[0])
        
        if word['chinese'] not in existing_words:
            with open(self.revision_file, 'a', encoding='utf-8') as f:
                f.write(f"{word['chinese']}|{word['pinyin']}|{word['meaning']}|"
                       f"{word.get('han_viet', '')}|{word.get('nghia_tieng_viet', '')}|"
                       f"{word.get('cach_dung', '')}\n")
    
    def remove_word_from_revision(self, word):
        """Remove a word from revision.txt"""
        if not self.revision_file.exists():
            return
        
        remaining_words = []
        with open(self.revision_file, 'r', encoding='utf-8') as f:
            for line in f:
                parts = line.strip().split('|')
                if len(parts) >= 1 and parts[0] != word['chinese']:
                    remaining_words.append(line)
        
        with open(self.revision_file, 'w', encoding='utf-8') as f:
            f.writelines(remaining_words)
    
    def run(self):
        """Run the application"""
        self.root.mainloop()


class FlashcardWindow:
    def __init__(self, parent, words, app, is_test=False, is_revision=False):
        self.app = app
        self.words = words.copy()
        random.shuffle(self.words)
        self.is_test = is_test
        self.is_revision = is_revision
        self.current_index = 0
        self.correct_count = 0
        self.wrong_words = []
        
        # Create window
        self.window = tk.Toplevel(parent)
        self.window.title("Test" if is_test else "Learn")
        self.window.geometry("700x600")
        self.window.configure(bg="#F5F5F5")
        
        self.create_ui()
        self.show_word()
    
    def create_ui(self):
        """Create flashcard UI"""
        # Progress
        progress_frame = tk.Frame(self.window, bg="white", relief=tk.RAISED, bd=2)
        progress_frame.pack(pady=10, padx=20, fill=tk.X)
        
        self.progress_label = tk.Label(progress_frame, text="", 
                                       font=("Arial", 12, "bold"), 
                                       bg="white", fg="#2196F3", pady=10)
        self.progress_label.pack()
        
        # Question area
        question_frame = tk.Frame(self.window, bg="white", relief=tk.RAISED, bd=2)
        question_frame.pack(pady=10, padx=20, fill=tk.BOTH, expand=True)
        
        self.question_type_label = tk.Label(question_frame, text="", 
                                            font=("Arial", 14), 
                                            bg="white", fg="#666666", pady=10)
        self.question_type_label.pack()
        
        self.question_label = tk.Label(question_frame, text="", 
                                       font=("Arial", 36, "bold"), 
                                       bg="white", fg="#00BCD4", pady=20, wraplength=600,
                                       justify=tk.LEFT)
        self.question_label.pack()
        
        # Additional labels for colored answer display
        self.chinese_label = tk.Label(question_frame, text="", 
                                     font=("Arial", 36, "bold"), 
                                     bg="white", fg="#FF5722", pady=5)
        
        self.pinyin_label = tk.Label(question_frame, text="", 
                                    font=("Arial", 24, "bold"), 
                                    bg="white", fg="#2196F3", pady=5)
        
        self.meaning_label = tk.Label(question_frame, text="", 
                                     font=("Arial", 20), 
                                     bg="white", fg="#4CAF50", pady=5)
        
        self.hanviet_label = tk.Label(question_frame, text="", 
                                     font=("Arial", 18), 
                                     bg="white", fg="#9C27B0", pady=5)
        
        self.vietnamese_label = tk.Label(question_frame, text="", 
                                        font=("Arial", 18), 
                                        bg="white", fg="#FF9800", pady=5)
        
        hint_label = tk.Label(question_frame, text="Type the pinyin (use 1234 for tones)", 
                             font=("Arial", 10), bg="white", fg="#999999")
        hint_label.pack()
        
        # Answer input
        answer_frame = tk.Frame(self.window, bg="white", relief=tk.RAISED, bd=2)
        answer_frame.pack(pady=10, padx=20, fill=tk.X)
        
        self.answer_entry = tk.Entry(answer_frame, font=("Arial", 16), 
                                     justify=tk.CENTER, bd=2, relief=tk.GROOVE)
        self.answer_entry.pack(pady=15, padx=20, fill=tk.X)
        self.answer_entry.bind('<Return>', lambda e: self.check_answer())
        self.answer_entry.focus()
        
        # Feedback area
        self.feedback_frame = tk.Frame(self.window, bg="white", relief=tk.RAISED, bd=2)
        self.feedback_label = tk.Label(self.feedback_frame, text="", 
                                       font=("Arial", 14, "bold"), pady=10)
        self.feedback_label.pack()
        
        # Buttons
        button_frame = tk.Frame(self.window, bg="#F5F5F5")
        button_frame.pack(pady=10, padx=20, fill=tk.X)
        
        self.submit_btn = tk.Button(button_frame, text="Submit", 
                                    font=("Arial", 12), bg="#4CAF50", fg="white", 
                                    height=2, command=self.check_answer)
        self.submit_btn.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5))
        
        self.next_btn = tk.Button(button_frame, text="Next", 
                                  font=("Arial", 12), bg="#2196F3", fg="white", 
                                  height=2, command=self.next_word)
        
        self.finish_btn = tk.Button(button_frame, text="Finish", 
                                    font=("Arial", 12), bg="#9C27B0", fg="white", 
                                    height=2, command=self.finish_session)
    
    def show_word(self):
        """Show current word"""
        if self.current_index >= len(self.words):
            if not self.is_test:
                # Endless mode - reshuffle
                random.shuffle(self.words)
                self.current_index = 0
                messagebox.showinfo("Round Complete", "Starting new round...")
            else:
                self.finish_session()
                return
        
        word = self.words[self.current_index]
        self.current_word = word
        
        # Update progress
        self.progress_label.config(text=f"{'Question' if self.is_test else 'Word'} {self.current_index + 1}/{len(self.words)}")
        
        # Show question
        if self.is_test or random.random() < 0.5:
            self.show_chinese = True
            self.question_type_label.config(text="Chinese:")
            self.question_label.config(text=word['chinese'])
        else:
            self.show_chinese = False
            self.question_type_label.config(text="Meaning:")
            self.question_label.config(text=word['meaning'])
        
        # Reset UI
        self.answer_entry.config(state=tk.NORMAL)
        self.answer_entry.delete(0, tk.END)
        self.answer_entry.insert(0, "")
        self.feedback_frame.pack_forget()
        self.submit_btn.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5))
        self.next_btn.pack_forget()
        self.finish_btn.pack_forget()
        self.answer_entry.focus()
        
        # Hide colored answer labels and show question label
        self.chinese_label.pack_forget()
        self.pinyin_label.pack_forget()
        self.meaning_label.pack_forget()
        self.hanviet_label.pack_forget()
        self.vietnamese_label.pack_forget()
        self.question_label.pack()
        
        # Rebind Enter key to submit answer
        self.window.unbind('<Return>')
        self.answer_entry.bind('<Return>', lambda e: self.check_answer())
    
    def check_answer(self):
        """Check user's answer"""
        user_answer = self.answer_entry.get().strip()
        if not user_answer:
            messagebox.showwarning("Warning", "Please enter an answer")
            return
        
        word = self.current_word
        correct = self.check_pinyin(user_answer, word['pinyin'])
        
        # Update UI
        self.answer_entry.config(state=tk.DISABLED)
        self.submit_btn.pack_forget()
        self.feedback_frame.pack(pady=10, padx=20, fill=tk.X)
        
        # Hide single question label and show colored multi-line answer
        self.question_label.pack_forget()
        self.question_type_label.config(text="Answer:")
        
        # Show answer with different colors for each line
        self.chinese_label.config(text=word['chinese'])
        self.chinese_label.pack()
        
        self.pinyin_label.config(text=self.convert_tone_marks(word['pinyin']))
        self.pinyin_label.pack()
        
        self.meaning_label.config(text=word['meaning'])
        self.meaning_label.pack()
        
        if word.get('han_viet'):
            self.hanviet_label.config(text=f"Hán Việt: {word['han_viet']}")
            self.hanviet_label.pack()
        else:
            self.hanviet_label.pack_forget()
        
        if word.get('nghia_tieng_viet'):
            self.vietnamese_label.config(text=word['nghia_tieng_viet'])
            self.vietnamese_label.pack()
        else:
            self.vietnamese_label.pack_forget()
        
        # Show feedback
        if correct:
            self.feedback_label.config(text="✓ Correct!", fg="#4CAF50", bg="#E8F5E9")
            self.feedback_frame.config(bg="#E8F5E9")
            self.correct_count += 1
        else:
            self.feedback_label.config(text="✗ Incorrect", fg="#F44336", bg="#FFEBEE")
            self.feedback_frame.config(bg="#FFEBEE")
            
            if self.is_test:
                self.wrong_words.append(word)
        
        # Show next/finish button
        if self.current_index < len(self.words) - 1 or not self.is_test:
            self.next_btn.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(5, 0))
            # Bind Enter key to next word
            self.answer_entry.unbind('<Return>')
            self.window.bind('<Return>', lambda e: self.next_word())
        else:
            self.finish_btn.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(5, 0))
            # Bind Enter key to finish
            self.answer_entry.unbind('<Return>')
            self.window.bind('<Return>', lambda e: self.finish_session())
    
    def next_word(self):
        """Move to next word"""
        self.current_index += 1
        self.show_word()
    
    def finish_session(self):
        """Finish the session"""
        if self.is_test:
            # Save wrong words to revision
            if not self.is_revision:
                for word in self.wrong_words:
                    self.app.save_word_to_revision(word)
            else:
                # Remove correct words from revision
                for word in self.words:
                    if word not in self.wrong_words:
                        self.app.remove_word_from_revision(word)
            
            # Show results
            score = (self.correct_count / len(self.words)) * 100 if self.words else 0
            result_msg = f"Score: {self.correct_count}/{len(self.words)} ({score:.1f}%)\n\n"
            
            if self.is_revision:
                remaining = len(self.words) - self.correct_count
                result_msg += f"Words removed from revision: {self.correct_count}\n"
                result_msg += f"Words remaining in revision: {remaining}"
            else:
                result_msg += f"Wrong words saved to revision: {len(self.wrong_words)}"
            
            messagebox.showinfo("Test Complete!", result_msg)
        
        self.window.destroy()
        self.app.create_main_menu()
    
    @staticmethod
    def check_pinyin(user_input, correct_pinyin):
        """Check if pinyin is correct"""
        tone_map = {
            'ā': 'a1', 'á': 'a2', 'ǎ': 'a3', 'à': 'a4',
            'ē': 'e1', 'é': 'e2', 'ě': 'e3', 'è': 'e4',
            'ī': 'i1', 'í': 'i2', 'ǐ': 'i3', 'ì': 'i4',
            'ō': 'o1', 'ó': 'o2', 'ǒ': 'o3', 'ò': 'o4',
            'ū': 'u1', 'ú': 'u2', 'ǔ': 'u3', 'ù': 'u4',
            'ǖ': 'ü1', 'ǘ': 'ü2', 'ǚ': 'ü3', 'ǜ': 'ü4',
            'ü': 'v', 'ń': 'n2', 'ň': 'n3', 'ǹ': 'n4'
        }
        
        correct_normalized = correct_pinyin.lower()
        for mark, num in tone_map.items():
            correct_normalized = correct_normalized.replace(mark, num)
        
        user_normalized = user_input.lower().replace(' ', '').replace(',', '').replace('ü', 'v')
        correct_normalized = correct_normalized.replace(' ', '').replace(',', '')
        
        return user_normalized == correct_normalized
    
    @staticmethod
    def convert_tone_marks(pinyin):
        """Convert tone marks to numbers"""
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


class TestSetupDialog:
    def __init__(self, parent, app):
        self.app = app
        self.dialog = tk.Toplevel(parent)
        self.dialog.title("Test Setup")
        self.dialog.geometry("400x200")
        self.dialog.configure(bg="#F5F5F5")
        
        label = tk.Label(self.dialog, text="How many previous patches to test?", 
                        font=("Arial", 14), bg="#F5F5F5", pady=20)
        label.pack()
        
        self.var = tk.IntVar(value=1)
        max_patches = app.progress['current_index']
        
        for i in range(1, max_patches + 1):
            text = f"{i} patch" if i == 1 else f"{i} patches"
            rb = tk.Radiobutton(self.dialog, text=text, variable=self.var, 
                               value=i, font=("Arial", 12), bg="#F5F5F5")
            rb.pack(anchor=tk.W, padx=40)
        
        btn_frame = tk.Frame(self.dialog, bg="#F5F5F5")
        btn_frame.pack(pady=20)
        
        btn_ok = tk.Button(btn_frame, text="Start Test", font=("Arial", 12), 
                          bg="#4CAF50", fg="white", command=self.start_test)
        btn_ok.pack(side=tk.LEFT, padx=5)
        
        btn_cancel = tk.Button(btn_frame, text="Cancel", font=("Arial", 12), 
                              bg="#757575", fg="white", command=self.dialog.destroy)
        btn_cancel.pack(side=tk.LEFT, padx=5)
    
    def start_test(self):
        num_patches = self.var.get()
        words = self.get_test_words(num_patches)
        self.dialog.destroy()
        FlashcardWindow(self.app.root, words, self.app, is_test=True, is_revision=False)
    
    def get_test_words(self, num_patches):
        """Get test words from previous patches"""
        words_per_patch = self.app.config['words_per_patch']
        current_idx = self.app.progress['current_index']
        shuffled_indices = self.app.progress['shuffled_indices']
        
        max_patches = min(num_patches, current_idx)
        start = (current_idx - max_patches) * words_per_patch
        end = current_idx * words_per_patch
        
        test_indices = shuffled_indices[start:end]
        return [self.app.words[i] for i in test_indices]


class ConfigWindow:
    def __init__(self, parent, app):
        self.app = app
        self.window = tk.Toplevel(parent)
        self.window.title("Configuration")
        self.window.geometry("500x400")
        self.window.configure(bg="#F5F5F5")
        
        title = tk.Label(self.window, text="Configuration", 
                        font=("Arial", 20, "bold"), fg="#2196F3", bg="#F5F5F5")
        title.pack(pady=20)
        
        # HSK Level
        hsk_frame = tk.Frame(self.window, bg="white", relief=tk.RAISED, bd=2)
        hsk_frame.pack(pady=10, padx=40, fill=tk.X)
        
        tk.Label(hsk_frame, text="HSK Level", font=("Arial", 14, "bold"), 
                bg="white", pady=10).pack(anchor=tk.W, padx=10)
        tk.Label(hsk_frame, text="Select your HSK level (1-6)", font=("Arial", 10), 
                bg="white", fg="#666666").pack(anchor=tk.W, padx=10)
        
        self.hsk_var = tk.IntVar(value=app.config['hsk_level'])
        hsk_combo = ttk.Combobox(hsk_frame, textvariable=self.hsk_var, 
                                values=[1, 2, 3, 4, 5, 6], state='readonly', 
                                font=("Arial", 12))
        hsk_combo.pack(pady=10, padx=10, fill=tk.X)
        
        # Words per patch
        words_frame = tk.Frame(self.window, bg="white", relief=tk.RAISED, bd=2)
        words_frame.pack(pady=10, padx=40, fill=tk.X)
        
        tk.Label(words_frame, text="Words Per Patch", font=("Arial", 14, "bold"), 
                bg="white", pady=10).pack(anchor=tk.W, padx=10)
        tk.Label(words_frame, text="Number of words in each learning patch", 
                font=("Arial", 10), bg="white", fg="#666666").pack(anchor=tk.W, padx=10)
        
        self.words_entry = tk.Entry(words_frame, font=("Arial", 12))
        self.words_entry.insert(0, str(app.config['words_per_patch']))
        self.words_entry.pack(pady=10, padx=10, fill=tk.X)
        
        # Reset progress
        reset_frame = tk.Frame(self.window, bg="white", relief=tk.RAISED, bd=2)
        reset_frame.pack(pady=10, padx=40, fill=tk.X)
        
        tk.Label(reset_frame, text="Reset Progress", font=("Arial", 14, "bold"), 
                bg="white", pady=10).pack(anchor=tk.W, padx=10)
        tk.Label(reset_frame, text="Reshuffle all words and start from the beginning", 
                font=("Arial", 10), bg="white", fg="#666666").pack(anchor=tk.W, padx=10)
        
        btn_reset = tk.Button(reset_frame, text="Reset Progress", font=("Arial", 12), 
                             bg="#FF5722", fg="white", command=self.reset_progress)
        btn_reset.pack(pady=10, padx=10, fill=tk.X)
        
        # Save button
        btn_save = tk.Button(self.window, text="💾 Save Configuration", 
                            font=("Arial", 14), bg="#4CAF50", fg="white", 
                            height=2, command=self.save_config)
        btn_save.pack(pady=20, padx=40, fill=tk.X)
    
    def reset_progress(self):
        """Reset progress"""
        if messagebox.askyesno("Confirm", "Are you sure you want to reset progress? This will reshuffle all words and start from the beginning."):
            self.app.progress['shuffled_indices'] = list(range(len(self.app.words)))
            random.shuffle(self.app.progress['shuffled_indices'])
            self.app.progress['current_index'] = 0
            self.app.save_progress()
            messagebox.showinfo("Success", "Progress has been reset!")
    
    def save_config(self):
        """Save configuration"""
        try:
            new_hsk = self.hsk_var.get()
            new_words = int(self.words_entry.get())
            
            if new_words <= 0:
                messagebox.showerror("Error", "Please enter a positive number for words per patch")
                return
            
            old_hsk = self.app.config['hsk_level']
            self.app.config['hsk_level'] = new_hsk
            self.app.config['words_per_patch'] = new_words
            self.app.save_config()
            
            if new_hsk != old_hsk:
                self.app.load_words()
                messagebox.showinfo("Success", "HSK level changed. Progress has been reset.")
            else:
                messagebox.showinfo("Success", "Configuration saved!")
            
            self.window.destroy()
            self.app.create_main_menu()
        except ValueError:
            messagebox.showerror("Error", "Please enter a valid number for words per patch")


def main():
    app = ChineseFlashcardGUI()
    app.run()


if __name__ == "__main__":
    main()
