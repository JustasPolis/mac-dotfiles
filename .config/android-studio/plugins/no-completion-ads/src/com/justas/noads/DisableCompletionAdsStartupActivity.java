package com.justas.noads;

import com.intellij.codeInsight.AutoPopupController;
import com.intellij.openapi.editor.Editor;
import com.intellij.openapi.editor.EditorFactory;
import com.intellij.openapi.editor.event.EditorFactoryEvent;
import com.intellij.openapi.editor.event.EditorFactoryListener;
import com.intellij.openapi.project.DumbAware;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.startup.StartupActivity;

public final class DisableCompletionAdsStartupActivity implements StartupActivity, DumbAware {
  @Override
  public void runActivity(Project project) {
    EditorFactory editorFactory = EditorFactory.getInstance();

    for (Editor editor : editorFactory.getAllEditors()) {
      if (project.equals(editor.getProject())) {
        disableAdvertisements(editor);
      }
    }

    editorFactory.addEditorFactoryListener(new EditorFactoryListener() {
      @Override
      public void editorCreated(EditorFactoryEvent event) {
        Editor editor = event.getEditor();
        if (project.equals(editor.getProject())) {
          disableAdvertisements(editor);
        }
      }
    }, project);
  }

  private static void disableAdvertisements(Editor editor) {
    editor.putUserData(AutoPopupController.NO_ADS, Boolean.TRUE);
  }
}
