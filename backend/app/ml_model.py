"""
ML Model loader and prediction engine.
Supports both v1 (9 features) and v2 (15 features) model formats.
"""

import os
import numpy as np
import pandas as pd
import joblib


class AcademyFlowModel:

    def __init__(self):
        self.model_package = None
        self.model_loaded = False
        self.model_type = None
        self._version = "1.0"

    def load(self) -> bool:
        search_paths = [
            "enhanced_model.pkl",
            "model.pkl",
            "../MLmodels/enhanced_model.pkl",
            "../MLmodels/model.pkl",
            "MLmodels/enhanced_model.pkl",
            "MLmodels/model.pkl",
        ]

        for path in search_paths:
            if os.path.exists(path):
                try:
                    model_package = joblib.load(path)
                    if isinstance(model_package, dict):
                        self.model_package = model_package
                        self.model_loaded = True
                        self.model_type = "enhanced"
                        self._version = model_package.get("version", "1.0")
                        print(f"Loaded enhanced model v{self._version} from: {path}")
                        return True
                    else:
                        self.model_package = {"best_model": model_package}
                        self.model_loaded = True
                        self.model_type = "basic"
                        print(f"Loaded basic model from: {path}")
                        return True
                except Exception as e:
                    print(f"Failed to load model from {path}: {e}")
                    continue

        print("ERROR: No model file found!")
        return False

    @property
    def model_name(self) -> str:
        if not self.model_loaded:
            return "Not loaded"
        return self.model_package.get("best_model_name", "Linear Regression")

    @staticmethod
    def calculate_engineered_features(
        hours: int, prev_score: int, extra: int, sleep: int, papers: int
    ) -> dict:
        return {
            "Study_Sleep_Ratio": hours / (sleep + 1),
            "Total_Effort": hours + papers,
            "Previous_Score_Normalized": prev_score / 100,
            "Sleep_Efficiency": sleep * prev_score / 100,
        }

    @staticmethod
    def _calculate_v2_features(
        hours: int, prev_score: int, extra: int, sleep: int, papers: int
    ) -> dict:
        prev_norm = prev_score / 100
        total_effort = hours + papers
        sleep_eff = sleep * prev_norm
        return {
            "Study_Sleep_Ratio": hours / (sleep + 1),
            "Total_Effort": total_effort,
            "Previous_Score_Normalized": prev_norm,
            "Sleep_Efficiency": sleep_eff,
            "Study_Score_Interaction": hours * prev_norm,
            "Effort_Efficiency": total_effort * prev_norm,
            "Study_Squared": hours ** 2,
            "Score_Squared": prev_norm ** 2,
            "Papers_Per_Hour": papers / (hours + 1),
            "Balanced_Lifestyle": sleep_eff * (extra if extra else 0.5),
        }

    def predict(
        self,
        hours_studied: int,
        previous_scores: int,
        extracurricular: int,
        sleep_hours: int,
        sample_papers: int,
    ) -> float:
        if not self.model_loaded:
            raise RuntimeError("Model not loaded. Call load() first.")

        if self.model_type == "enhanced":
            feature_names = self.model_package.get("feature_names", [])
            use_v2 = "Study_Score_Interaction" in feature_names

            if use_v2:
                eng = self._calculate_v2_features(
                    hours_studied, previous_scores, extracurricular,
                    sleep_hours, sample_papers,
                )
                features_df = pd.DataFrame({
                    "Hours Studied": [hours_studied],
                    "Previous Scores": [previous_scores],
                    "Extracurricular Activities": [extracurricular],
                    "Sleep Hours": [sleep_hours],
                    "Sample Question Papers Practiced": [sample_papers],
                    **{k: [v] for k, v in eng.items()},
                })
            else:
                eng = self.calculate_engineered_features(
                    hours_studied, previous_scores, extracurricular,
                    sleep_hours, sample_papers,
                )
                features_df = pd.DataFrame({
                    "Hours Studied": [hours_studied],
                    "Previous Scores": [previous_scores],
                    "Extracurricular Activities": [extracurricular],
                    "Sleep Hours": [sleep_hours],
                    "Sample Question Papers Practiced": [sample_papers],
                    "Study_Sleep_Ratio": [eng["Study_Sleep_Ratio"]],
                    "Total_Effort": [eng["Total_Effort"]],
                    "Previous_Score_Normalized": [eng["Previous_Score_Normalized"]],
                    "Sleep_Efficiency": [eng["Sleep_Efficiency"]],
                })

            model = self.model_package["best_model"]
        else:
            features_df = np.array(
                [[hours_studied, previous_scores, extracurricular, sleep_hours, sample_papers]]
            )
            model = self.model_package["best_model"]

        prediction = float(model.predict(features_df)[0])
        prediction = np.clip(prediction, 0, 100)

        return prediction


model_instance = AcademyFlowModel()
