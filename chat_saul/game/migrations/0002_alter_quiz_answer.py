# Generated by Django 5.1.3 on 2024-11-10 07:20

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("game", "0001_initial"),
    ]

    operations = [
        migrations.AlterField(
            model_name="quiz",
            name="answer",
            field=models.PositiveSmallIntegerField(
                choices=[
                    (1, "Option 1"),
                    (2, "Option 2"),
                    (3, "Option 3"),
                    (4, "Option 4"),
                ]
            ),
        ),
    ]
