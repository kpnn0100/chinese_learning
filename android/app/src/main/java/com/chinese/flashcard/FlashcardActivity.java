package com.chinese.flashcard;

import android.graphics.Color;
import android.os.Bundle;
import android.text.Html;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;

public class FlashcardActivity extends AppCompatActivity {

    private FlashcardManager manager;
    private List<ChineseWord> words;
    private int currentWordIndex = 0;
    private boolean isAnswered = false;
    private String mode; // "normal" or "revision"
    private Random random = new Random();

    private TextView tvProgress, tvQuestionType, tvQuestion, tvHint;
    private TextView tvFeedback, tvAnswer;
    private EditText etAnswer;
    private Button btnSubmit, btnNext, btnFinish;
    private CardView cardFeedback;
    private ProgressBar progressBar;

    private boolean showChinese; // true = show Chinese, false = show meaning

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_flashcard);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        manager = new FlashcardManager(this);
        mode = getIntent().getStringExtra("mode");

        initViews();
        loadWords();
        showNextWord();
    }

    private void initViews() {
        tvProgress = findViewById(R.id.tvProgress);
        tvQuestionType = findViewById(R.id.tvQuestionType);
        tvQuestion = findViewById(R.id.tvQuestion);
        tvHint = findViewById(R.id.tvHint);
        tvFeedback = findViewById(R.id.tvFeedback);
        tvAnswer = findViewById(R.id.tvAnswer);
        etAnswer = findViewById(R.id.etAnswer);
        btnSubmit = findViewById(R.id.btnSubmit);
        btnNext = findViewById(R.id.btnNext);
        btnFinish = findViewById(R.id.btnFinish);
        cardFeedback = findViewById(R.id.cardFeedback);
        progressBar = findViewById(R.id.progressBar);

        btnSubmit.setOnClickListener(v -> checkAnswer());
        btnNext.setOnClickListener(v -> nextWord());
        btnFinish.setOnClickListener(v -> finish());
    }

    private void loadWords() {
        if ("revision".equals(mode)) {
            words = new ArrayList<>(manager.loadRevisionWords());
            setTitle("Practice Revision Words");
        } else {
            words = new ArrayList<>(manager.getCurrentPatch());
            setTitle("Learn Current Patch");
        }
        Collections.shuffle(words);
    }

    private void showNextWord() {
        if (currentWordIndex >= words.size()) {
            // Reshuffle and continue (endless mode)
            Collections.shuffle(words);
            currentWordIndex = 0;
            Toast.makeText(this, "Round complete! Starting new round...", Toast.LENGTH_SHORT).show();
        }

        ChineseWord word = words.get(currentWordIndex);
        isAnswered = false;

        // Update progress
        tvProgress.setText("Word " + (currentWordIndex + 1) + "/" + words.size());
        progressBar.setMax(words.size());
        progressBar.setProgress(currentWordIndex + 1);

        // Randomly choose question type
        showChinese = random.nextBoolean();

        if (showChinese) {
            tvQuestionType.setText("Chinese:");
            tvQuestion.setText(Html.fromHtml("<font color='#00BCD4'><b>" + 
                             word.getChinese() + "</b></font>", Html.FROM_HTML_MODE_LEGACY));
        } else {
            tvQuestionType.setText("Meaning:");
            tvQuestion.setText(word.getMeaning());
        }

        // Reset UI
        etAnswer.setText("");
        etAnswer.setEnabled(true);
        cardFeedback.setVisibility(View.GONE);
        btnSubmit.setVisibility(View.VISIBLE);
        btnNext.setVisibility(View.GONE);
        btnFinish.setVisibility(View.GONE);
        etAnswer.requestFocus();
    }

    private void checkAnswer() {
        if (isAnswered) return;

        String userAnswer = etAnswer.getText().toString().trim();
        if (userAnswer.isEmpty()) {
            Toast.makeText(this, "Please enter an answer", Toast.LENGTH_SHORT).show();
            return;
        }

        ChineseWord word = words.get(currentWordIndex);
        boolean correct = word.checkPinyinAnswer(userAnswer);

        isAnswered = true;
        etAnswer.setEnabled(false);
        cardFeedback.setVisibility(View.VISIBLE);
        btnSubmit.setVisibility(View.GONE);

        // Show feedback
        StringBuilder answerText = new StringBuilder();
        
        if (correct) {
            tvFeedback.setText("✓ Correct!");
            tvFeedback.setTextColor(Color.parseColor("#4CAF50"));
            cardFeedback.setCardBackgroundColor(Color.parseColor("#E8F5E9"));
        } else {
            tvFeedback.setText("✗ Incorrect");
            tvFeedback.setTextColor(Color.parseColor("#F44336"));
            cardFeedback.setCardBackgroundColor(Color.parseColor("#FFEBEE"));
            answerText.append("Correct answer: ").append(word.getDisplayPinyin()).append("\n\n");
        }

        // Show all information
        if (showChinese) {
            answerText.append("Meaning: ").append(word.getMeaning()).append("\n");
        } else {
            answerText.append("Chinese: ").append(word.getChinese()).append("\n");
            answerText.append("Pinyin: ").append(word.getDisplayPinyin()).append("\n");
        }

        if (!word.getHanViet().isEmpty()) {
            answerText.append("Hán Việt: ").append(word.getHanViet()).append("\n");
        }
        if (!word.getNghiaTiengViet().isEmpty()) {
            answerText.append("Nghĩa Tiếng Việt: ").append(word.getNghiaTiengViet()).append("\n");
        }
        if (!word.getCachDung().isEmpty()) {
            answerText.append("Cách dùng: ").append(word.getCachDung()).append("\n");
        }

        tvAnswer.setText(answerText.toString().trim());

        // Show appropriate button
        if (currentWordIndex < words.size() - 1 || words.size() >= 2) {
            btnNext.setVisibility(View.VISIBLE);
        } else {
            btnFinish.setVisibility(View.VISIBLE);
        }
    }

    private void nextWord() {
        currentWordIndex++;
        showNextWord();
    }

    @Override
    public boolean onSupportNavigateUp() {
        finish();
        return true;
    }
}
