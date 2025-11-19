package com.chinese.flashcard;

import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    private FlashcardManager manager;
    private TextView tvHskLevel, tvPatchInfo, tvWordsInfo;
    private Button btnStart, btnNext, btnPrevious, btnTest;
    private Button btnStartRevision, btnTestRevision, btnConfig, btnExit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        manager = new FlashcardManager(this);

        initViews();
        updateInfo();
        setupListeners();
    }

    @Override
    protected void onResume() {
        super.onResume();
        manager = new FlashcardManager(this);
        updateInfo();
    }

    private void initViews() {
        tvHskLevel = findViewById(R.id.tvHskLevel);
        tvPatchInfo = findViewById(R.id.tvPatchInfo);
        tvWordsInfo = findViewById(R.id.tvWordsInfo);

        btnStart = findViewById(R.id.btnStart);
        btnNext = findViewById(R.id.btnNext);
        btnPrevious = findViewById(R.id.btnPrevious);
        btnTest = findViewById(R.id.btnTest);
        btnStartRevision = findViewById(R.id.btnStartRevision);
        btnTestRevision = findViewById(R.id.btnTestRevision);
        btnConfig = findViewById(R.id.btnConfig);
        btnExit = findViewById(R.id.btnExit);
    }

    private void updateInfo() {
        tvHskLevel.setText("HSK Level: " + manager.getHskLevel() + 
                          " | Words per patch: " + manager.getWordsPerPatch());
        tvPatchInfo.setText("Current Patch: " + (manager.getCurrentIndex() + 1) + 
                           "/" + manager.getTotalPatches());
        tvWordsInfo.setText("Total Words: " + manager.getTotalWords() + 
                          " | Revision: " + manager.getRevisionCount());
    }

    private void setupListeners() {
        btnStart.setOnClickListener(v -> {
            if (manager.getCurrentPatch().isEmpty()) {
                Toast.makeText(this, "No more words! You've completed all patches.", 
                             Toast.LENGTH_SHORT).show();
            } else {
                Intent intent = new Intent(MainActivity.this, FlashcardActivity.class);
                intent.putExtra("mode", "normal");
                startActivity(intent);
            }
        });

        btnNext.setOnClickListener(v -> {
            if (manager.canMoveNext()) {
                manager.moveNext();
                updateInfo();
                Toast.makeText(this, "Moved to patch " + (manager.getCurrentIndex() + 1), 
                             Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this, "You're already at the last patch!", 
                             Toast.LENGTH_SHORT).show();
            }
        });

        btnPrevious.setOnClickListener(v -> {
            if (manager.canMovePrevious()) {
                manager.movePrevious();
                updateInfo();
                Toast.makeText(this, "Moved to patch " + (manager.getCurrentIndex() + 1), 
                             Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this, "You're already at the first patch!", 
                             Toast.LENGTH_SHORT).show();
            }
        });

        btnTest.setOnClickListener(v -> {
            if (manager.getCurrentIndex() == 0) {
                Toast.makeText(this, "No previous patches to test! Learn the first patch first.", 
                             Toast.LENGTH_SHORT).show();
            } else {
                showTestDialog();
            }
        });

        btnStartRevision.setOnClickListener(v -> {
            if (manager.getRevisionCount() == 0) {
                Toast.makeText(this, "No words in revision! Your revision list is empty.", 
                             Toast.LENGTH_SHORT).show();
            } else {
                Intent intent = new Intent(MainActivity.this, FlashcardActivity.class);
                intent.putExtra("mode", "revision");
                startActivity(intent);
            }
        });

        btnTestRevision.setOnClickListener(v -> {
            if (manager.getRevisionCount() == 0) {
                Toast.makeText(this, "No words in revision! Your revision list is empty.", 
                             Toast.LENGTH_SHORT).show();
            } else {
                Intent intent = new Intent(MainActivity.this, TestActivity.class);
                intent.putExtra("mode", "revision");
                startActivity(intent);
            }
        });

        btnConfig.setOnClickListener(v -> {
            Intent intent = new Intent(MainActivity.this, ConfigActivity.class);
            startActivity(intent);
        });

        btnExit.setOnClickListener(v -> {
            new AlertDialog.Builder(this)
                .setTitle("Exit")
                .setMessage("Are you sure you want to exit?")
                .setPositiveButton("Yes", (dialog, which) -> finish())
                .setNegativeButton("No", null)
                .show();
        });
    }

    private void showTestDialog() {
        String[] options = new String[manager.getCurrentIndex()];
        for (int i = 0; i < manager.getCurrentIndex(); i++) {
            options[i] = (i + 1) + " patch" + (i == 0 ? "" : "es");
        }

        new AlertDialog.Builder(this)
            .setTitle("Test Previous Patches")
            .setItems(options, (dialog, which) -> {
                Intent intent = new Intent(MainActivity.this, TestActivity.class);
                intent.putExtra("mode", "normal");
                intent.putExtra("numPatches", which + 1);
                startActivity(intent);
            })
            .setNegativeButton("Cancel", null)
            .show();
    }
}
