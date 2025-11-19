package com.chinese.flashcard;

import android.app.AlertDialog;
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

public class TestActivity extends AppCompatActivity {

    private FlashcardManager manager;
    private List<ChineseWord> testWords;
    private List<ChineseWord> wrongWords;
    private int currentWordIndex = 0;
    private int correctCount = 0;
    private boolean isAnswered = false;
    private String mode; // "normal" or "revision"

    private TextView tvProgress, tvQuestionType, tvQuestion, tvHint;
    private TextView tvFeedback, tvAnswer;
    private EditText etAnswer;
    private Button btnSubmit, btnNext, btnFinish;
    private CardView cardFeedback;
    private ProgressBar progressBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_flashcard);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        manager = new FlashcardManager(this);
        mode = getIntent().getStringExtra("mode");
        wrongWords = new ArrayList<>();

        initViews();
        loadTestWords();
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
        btnFinish.setOnClickListener(v -> finishTest());
    }

    private void loadTestWords() {
        if ("revision".equals(mode)) {
            testWords = new ArrayList<>(manager.loadRevisionWords());
            setTitle("Test Revision");
        } else {
            int numPatches = getIntent().getIntExtra("numPatches", 1);
            testWords = new ArrayList<>(manager.getTestWords(numPatches));
            setTitle("Test Previous Patches");
        }
        Collections.shuffle(testWords);
    }

    private void showNextWord() {
        if (currentWordIndex >= testWords.size()) {
            finishTest();
            return;
        }

        ChineseWord word = testWords.get(currentWordIndex);
        isAnswered = false;

        // Update progress
        tvProgress.setText("Question " + (currentWordIndex + 1) + "/" + testWords.size());
        progressBar.setMax(testWords.size());
        progressBar.setProgress(currentWordIndex + 1);

        // Always show Chinese in test
        tvQuestionType.setText("Chinese:");
        tvQuestion.setText(Html.fromHtml("<font color='#00BCD4'><b>" + 
                         word.getChinese() + "</b></font>", Html.FROM_HTML_MODE_LEGACY));

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

        ChineseWord word = testWords.get(currentWordIndex);
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
            correctCount++;

            // For revision test, note that word will be removed
            if ("revision".equals(mode)) {
                answerText.append("This word will be removed from revision.\n\n");
            }
        } else {
            tvFeedback.setText("✗ Incorrect");
            tvFeedback.setTextColor(Color.parseColor("#F44336"));
            cardFeedback.setCardBackgroundColor(Color.parseColor("#FFEBEE"));
            answerText.append("Correct answer: ").append(word.getDisplayPinyin()).append("\n\n");
            
            // Save wrong word
            wrongWords.add(word);
            
            // For revision test, note that word will remain
            if ("revision".equals(mode)) {
                answerText.append("This word will remain in your revision list.\n\n");
            }
        }

        // Show all information
        answerText.append("Meaning: ").append(word.getMeaning()).append("\n");
        
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
        if (currentWordIndex < testWords.size() - 1) {
            btnNext.setVisibility(View.VISIBLE);
        } else {
            btnFinish.setVisibility(View.VISIBLE);
        }
    }

    private void nextWord() {
        currentWordIndex++;
        showNextWord();
    }

    private void finishTest() {
        // Save wrong words to revision (for normal test)
        if ("normal".equals(mode)) {
            for (ChineseWord word : wrongWords) {
                manager.saveWordToRevision(word);
            }
        } else if ("revision".equals(mode)) {
            // Remove correct words from revision
            for (ChineseWord word : testWords) {
                if (!wrongWords.contains(word)) {
                    manager.removeWordFromRevision(word);
                }
            }
        }

        // Show results
        float score = testWords.isEmpty() ? 0 : (correctCount * 100.0f / testWords.size());
        int remaining = testWords.size() - correctCount;

        StringBuilder message = new StringBuilder();
        message.append("Score: ").append(correctCount).append("/").append(testWords.size())
               .append(" (").append(String.format("%.1f", score)).append("%)\n\n");

        if ("revision".equals(mode)) {
            message.append("Words removed from revision: ").append(correctCount).append("\n");
            message.append("Words remaining in revision: ").append(remaining);
        } else {
            message.append("Wrong words saved to revision: ").append(wrongWords.size());
        }

        new AlertDialog.Builder(this)
            .setTitle("Test Complete!")
            .setMessage(message.toString())
            .setPositiveButton("OK", (dialog, which) -> finish())
            .setCancelable(false)
            .show();
    }

    @Override
    public boolean onSupportNavigateUp() {
        finish();
        return true;
    }
}
